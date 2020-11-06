
import React from 'react';
import { Badge } from 'reactstrap';
import EmbarkJS from '../../embarkArtifacts/embarkjs';

class Ethereum extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            latestBlock: null,
        }
    }

    componentDidMount() {
        EmbarkJS.onReady((err) => {
            !err && EmbarkJS.Blockchain.isAvailable().then(blockchainEnabled => {
                blockchainEnabled && web3.eth.getBlock('latest').then((latestBlock) => {
                    this.updateBlock(latestBlock);
                    this.subscribeEvents();
                });
            })
        });

    }
    componentWillUnmount(){
        this.unsubscribeEvents();
    }
    subscribeEvents(){
        this.setState({
            subscription: web3.eth.subscribe('newBlockHeaders')
            .on("data", (blockHeader) => this.updateBlock(blockHeader))
            .on("error", console.error)
        })
    }
    unsubscribeEvents() {
        const {subscription} = this.state;
        if(subscription){
            subscription.unsubscribe();
            this.setState({subscription:null});
        }
    }
    updateBlock(latestBlock) {
        this.setState({latestBlock});
        this.props.onBlockUpdate(latestBlock);
    }
    render() {
        const {latestBlock} = this.state;
        if(latestBlock){
            const now = new Date(latestBlock.timestamp*1000);
            return(<p><Badge color="success">Connected</Badge> Number: {latestBlock.number} | {now.toLocaleDateString()} {now.toLocaleTimeString()} | Gas Usage: {(latestBlock.gasUsed * 100 / latestBlock.gasLimit).toFixed(2) }%</p>)
        }else {
            return(<p><Badge color="danger">Not connected</Badge></p>)
        }
    }
}

export default Ethereum;