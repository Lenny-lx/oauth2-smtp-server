# OAuth2 Mail Server Container

This container runs an SMTP server that accepts mail (postfix) and forwards it via Office365 using OAuth2 authentication (msmtp).

## Setup

### 1. Get OAuth2 Refresh Token

Create an Appregistration in Microsoft Azure with SMTP.Send permissions and grant admin consent. 
You need to obtain a refresh token. Update the credentials in `.env` (rename or copy .env.example to .env) with your app specific:
- `TENANT`: Your Azure tenant ID
- `CLIENT_ID`: Your app registration client ID
- `CLIENT_SECRET`: Your app registration client secret

Also define the Mail-Address for the Exchange Account in that file.
- `MAIL_ADDRESS`: Your SMTP Exchange account

### 1.2 MYNETWORKS

- `MYNETWORKS`: Type in your subnet range. Only incoming mails **FROM** this IP range will be accepted.
*Container enviroments mostly use 10.0.0.0/8 as the range.*
  

### 2. Store Refresh Token

### 2.1 Get the Refresh Token

Put this URL into you Browser for interactive login. 
Once it prompts you for E-Mail and password, login with your SMTP Exchange account (mail should be the same as in `MAIL_ADDRESS`):
```bash
https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/authorize?
client_id=<CLIENT_ID>&
response_type=code&
redirect_uri=http://localhost:8080&
response_mode=query&
scope=offline_access https://outlook.office365.com/SMTP.Send
```
Replace the vlaues `<CLIENT_ID>` and `<TENANT_ID>`. You get redirected to an error page:
Take the URL and copy the AUTH_CODE starting after `"http://localhost:8080/?code="` and before &session_state=.
(Should start with `"1.A..."`)

 
Run this command on the SMTP Host (use `AUTH_CODE`):
```bash
curl -s -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=<CLIENT_ID>" \
  -d "scope=offline_access https://outlook.office365.com/.default" \
  -d "code=<AUTH_CODE>" \
  -d "redirect_uri=http://localhost:8080" \
  -d "grant_type=authorization_code" \
  -d "client_secret=<CLIENT_SECRET>" \
  "https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token"
```
If everything is fine you get a json back. Copy the value for `refresh_token`.

Create a `refresh_token` file with your OAuth2 `refresh_token`:
```bash
echo "your_refresh_token_here" > msmtp/refresh_token
```


### 3. Build the Image
```bash
podman build -t oauth2-smtp-server .
```
```bash
docker build -t oauth2-smtp-server .
```

### 4. Run the Container
```bash
podman run -d \
  -p 25:25 \
  --name enter_name \
  --env-file ./.env \
  oauth2-smtp-server
```
```bash
docker run -d \
  -p 25:25 \
  --name enter_name \
  --env-file ./.env
  oauth2-smtp-server
```

## Usage

### Send mail to the container

You can use your hosts IP as the SMTP Server for printers and apps like usual. You can test the container by sending a mail to port 25.
In the follwing I used `msmtp` for sending the mail.

```bash
echo -e "Subject: Test\n\nThis is a test." | msmtp --host=localhost --port=25 -t recipient@example.com
```

Or from within the container:

```bash
echo -e "Subject: Test\n\nThis is a test." | msmtp --account=office365 recipient@example.com
```

### Check logs
```bash
podman exec msmtp-server cat /var/log/msmtp/msmtp.log
```
```bash
podman exec msmtp-server cat /var/log/postfix.log
```

```bash
docker exec msmtp-server cat /var/log/msmtp/msmtp.log
```
```bash
docker exec msmtp-server cat /var/log/postfix.log
```


## Configuration

- **msmtprc**: Main msmtp configuration
- **msmtp/oauth2_token**: Script to fetch fresh OAuth2 access tokens
