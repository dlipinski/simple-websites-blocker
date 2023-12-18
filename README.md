# Simple Website Blocker
Clean application to block websites on all browsers at once. Inspired by the inner need for digital detox.

<img src="https://github.com/dlipinski/simple-websites-blocker/blob/main/images/app_preview.png" width="426" height="533" alt="APP_PREVIEW">

## How does it work?

### MacOS

Blockades are set up in the `/etc/hosts` file.

#### Adding:
1. The user enters the site address (in any format, such as `site.com` or `https://www.site.com/subpage`) and clicks the `Block` button
2. A domain is extracted from the address (e.g. `https://www.site.com/subpage` -> `site.com`)
3. Address variants are created:  
    ```yaml
    <domain>
    www.<domain>
    http://<domain>
    https://<domain>
    http://www.<domain>
    https://www.<domain>
    ```
4. The user must authorize the operation so that the application can edit the `/etc/hosts` file
5. If it is the first addition, the fragment `# SimpleWebsitesBlockerStart#\nSimpleWebsitesBlockerEnd` is added to the `/etc/hosts` file
6. All variants are placed in the `/etc/hosts` file between the application tags (`# SimpleWebsitesBlockerStart`, `# SimpleWebsitesBlockerEnd`) in the format

    ```yaml
    # SimpleWebsitesBlockerStart
    ...
    127.0.0.1     <domain>
    127.0.0.1     www.<domain>
    127.0.0.1     http://<domain>
    127.0.0.1     https://<domain>
    127.0.0.1     http://www.<domain>
    127.0.0.1     https://www.<domain>
    ...
    # SimpleWebsitesBlockerEnd
    ```

#### Removal:
1. The user clicks on the `Unblock` button next to the domain
2. Address variants are created:  
    ```yaml
    <domain>
    www.<domain>
    http://<domain>
    https://<domain>
    http://www.<domain>
    https://www.<domain>
    ```
3. The user must authorize the operation so that the application can edit the `/etc/hosts` file
4. All variants are removed from the `/etc/hosts/` file

### Linux
Not yet supported.

### Windows
Not yet supported.

## Authorization examples

### MacOS
<img src="https://github.com/dlipinski/simple-websites-blocker/blob/main/images/osascript_preview.png" width="320" height="346" alt="APP_PREVIEW">

### Linux
Not yet supported.

### Windows
Not yet supported.


## Run in development mode
```sh
$ git clone https://github.com/dlipinski/simple-websites-blocker
$ cd simple-websites-blocker
$ flutter run
```

## Build and use

### MacOS

1. Clone project, build and open in XCode

    ```sh
    $ git clone https://github.com/dlipinski/simple-websites-blocker
    $ cd simple-websites-blocker
    $ flutter build macos
    $ open macos/Runner.xcodeproj 
    ```
2. In XCode in top menu, select `Product -> Build`
3. In left menu (Project navigator), find file `Runner -> Products -> Simple Websites Blocker`
4. Right-click and select `Show in Finder`
5. Copy `Simple Websites Blocker` to Desktop
6. Drag `Simple Websites Blocker` from Desktop to Applications