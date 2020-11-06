
import React from 'react';
import { Badge } from 'reactstrap';
import EmbarkJS from '../../embarkArtifacts/embarkjs';
class Account extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            accounts: null,
        }
    }
    componentDidMount() {
        EmbarkJS.onReady((err) => {
            if(!err) web3.eth.getAccounts().then((accounts) => this.setAccounts(accounts));
        });
    }
    setAccounts(accounts) {
        this.setState({accounts})
        this.props.onChange(accounts);
    }
    requestAccounts(){
        EmbarkJS.enableEthereum().then((accounts) => this.setAccounts(accounts));
    }
    render() {
        const {accounts} = this.state;
        if(accounts && accounts.length > 0){
            return(<small><Badge color="success">EIP1102 Authorized</Badge> {accounts[0]}</small>)
        }else {
            return(<small><Badge color="danger" onClick={()=>this.requestAccounts()}>EIP1102 Access Denied</Badge></small>)
        }
        
    }
}

export default Account;