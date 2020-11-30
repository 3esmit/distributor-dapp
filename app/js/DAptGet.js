
import React from 'react';
import EmbarkJS from '../../embarkArtifacts/embarkjs';
import DAptGet from '../../embarkArtifacts/contracts/DAptGet';
import { Input } from 'reactstrap';
import TransactionSubmitButton from './components/TransactionSubmitButton';

class DAptGetUI extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            appName: "",
            defaultAccount: null
        }
    }

    componentDidMount() {
        const defaultAccount = web3.eth.defaultAccount;
        console.log(defaultAccount);
        this.setState({ defaultAccount });
    }

    componentWillUnmount(){

    }

    render() {
        const {appName, defaultAccount} = this.state;
        return(<React.Fragment>
            <form>
                <label>
                    Nome:
                    <input value={appName} type="text" name="name" onChange={(e)=> { this.setState({appName: e.target.value })} } />
                </label>
                <TransactionSubmitButton account={defaultAccount} text="Cadastrar App" sendTransaction={DAptGet.methods.createApp(appName)} />
            </form>
        </React.Fragment>)
    }
}

export default DAptGetUI;