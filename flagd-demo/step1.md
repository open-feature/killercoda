## Your Username and Password
Certain commands will prompt for a username and password.

- Username: `openfeature`
- Password: `openfeature`

You can also log in to Gitea with these details.

## Push Flags to Gitea

This demo will use read a file from the local Git server. It is already available in `~/flags`{{}} but we need to push it to Gitea first.

Click the following and when prompted, use the username and password above.

```
cd ~/flags
git config credential.helper cache
git add example_flags.flagd.json
git commit -sm "add flags"
git push
```{{exec}}

# Gitea
Gitea is a local Git server. You can access it via these links.

Username and password is the same as you've just used.

[Login to Gitea]({{TRAFFIC_HOST1_3000}}/user/login)

[Open openfeature/flags repository]({{TRAFFIC_HOST1_3000}}/openfeature/flags)