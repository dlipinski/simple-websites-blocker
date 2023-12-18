# Simple Website Blocker
An application to block websites on all browsers at once. Inspired by the inner need for digital detox.

<img src="https://github.com/dlipinski/websites_blocker/blob/main/images/app_preview.png" width="533" height="667" alt="APP_PREVIEW">

## How does it work?

### MacOS / Linux

Blockades are set up in the `/etc/hosts` file.

#### Adding:
1. The user enters the site address (in any format, such as `site.com` or `https://www.site.com/subpage`) and clicks the `Block` button
2. A domain is extracted from the address (e.g. `https://www.site.com/subpage` -> `site.com`)
3. Address variants are created:  
    ```
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

    ```
    127.0.0.1     <domain>
    127.0.0.1     www.<domain>
    127.0.0.1     http://<domain>
    127.0.0.1     https://<domain>
    127.0.0.1     http://www.<domain>
    127.0.0.1     https://www.<domain>
    ```

#### Removal:
1. The user clicks on the `Unblock` button next to the domain
2. Address variants are created:  
    ```
    <domain>
    www.<domain>
    http://<domain>
    https://<domain>
    http://www.<domain>
    https://www.<domain>
    ```
3. The user must authorize the operation so that the application can edit the `/etc/hosts` file
4. All variants are removed from the `/etc/hosts/` file

## Authorization examples

### MacOS
<img src="https://github.com/dlipinski/websites_blocker/blob/main/images/osascript_preview.png" width="320" height="346" alt="APP_PREVIEW">