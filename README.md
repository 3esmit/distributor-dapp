# DAptGet

## Getting Started

0. clone repository and move into folder
    ```bash
    git clone git@github.com:3esmit/my-governance-example.git
    cd my-governance-example
    ```

1. install node 10.17.0, recommended using nvm https://github.com/creationix/nvm
    ```bash
    nvm install 10.17.0
    nvm alias default 10.17.0
    ```
2. install go-ethereum (geth)
    ```bash
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install geth -y
    ```
3. install a. `ipfs` or b. `swarm` and initialize it.  
    - IPFS:
        ```bash 
        sudo snap install ipfs
        ipfs init
        ```
    - SWARM:
        ```bash 
        #TODO
        ```
4. run unit test
    ```bash 
    npx embark test
    ```
5. run development environment
    ```bash 
    npx embark run
    ```
