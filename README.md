# Renovate Pipe
A custom Bitbucket pipe for running Renovate in Bitbucket as a scheduled pipeline.

## Environment Variables
| Variable Name        | Default     | Notes                                                                 |
|:---------------------|:------------|:----------------------------------------------------------------------|
| `RENOVATE_USERNAME ` | N/A         | Username of a Bitbucket account to run renovate as.                   |              
| `RENOVATE_PASSWORD ` | N/A         | App Password of the Bitbucket account.                                |
| `GITHUB_COM_TOKEN `  | N/A         | (Optional) Github Personal Access Token with `repo:public` permission |
| `CONFIG_FILE `       | `config.js` | (Optional) Directory where the base dependency files are.             |

All other environment variables found at https://docs.renovatebot.com/ can be used.

To create an app password see [here](https://docs.renovatebot.com/modules/platform/bitbucket/#authentication).

It is recommended to create a dedicated Bitbucket account to run the renovate pipe as. 

## Example Setup

```yaml
definitions:
  services:
    docker:
      memory: 3072

pipelines:
  custom:
    renovate:
      - step:
          name: "Run Renovate"
          script:
            - pipe: docker://aligent/renovate-pipe
              variables:
                RENOVATE_PASSWORD: $RENOVATE_PASSWORD
                RENOVATE_USERNAME: $RENOVATE_USERNAME
                GITHUB_COM_TOKEN: $GITHUB_COM_TOKEN
```