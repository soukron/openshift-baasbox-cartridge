# BaasBox in Openshift

This code allows you to run a BaasBox instance in Openshift. It's not actually a cartridge but a code to get when creating your DIY application.

Next features have been implemented:
 - Java installation
 - Baasbox installation
 - Openshift start/stop scripts
 - Change default *admin* password
 - Users creation
 - Collections creation
 - Documents creation
 - Plugins upload

# Installation
Create a DIY application getting this code as source:
```sh
$ rhc app create baasbox diy-0.1 --from-code https://github.com/soukron/openshift-baasbox-cartridge.git
```

# Configuration
Change next files to fit your needs: 
 - **misc/database-init.sh**:
   - *_password2*: it will be admin's password after initialization
   - *_collections*: array with names to be created as collections
   - *_users*: array with user accounts to be created
   - *_genres* and *_movies*: sample data to show documents creation with links between them and permissions
 - **misc/plugins/**:
   - every single file in this directory will be uploaded as a plugin and properly activated
   
# Other 
Database will be initialized when BaasBox is installed by default.

If you want to dump your database you can run next command from your console:
```sh
$ rhc ssh baasbox 'touch app-root/data/baasbox/.dbinit' 
```

Then restart your application to re-initialize it:
```sh
$ rhc app restart baasbox
```
Or push new changes to repository:
```sh
$ git push
```

Note that this process will dump all your data! Be careful!

# License
GPL



