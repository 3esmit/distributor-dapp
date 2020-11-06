import React from 'react';
import { Button, Spinner } from 'reactstrap';
import PropTypes from 'prop-types';

class TransactionSubmitButton extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            txWaiting: false
        };
    }

    static propTypes = {
        sendTransaction: PropTypes.object.isRequired,
        onSubmission: PropTypes.func,
        onReceipt: PropTypes.func,
        onResult: PropTypes.func,
        onError: PropTypes.func,
        account: PropTypes.string,
        text: PropTypes.any,
        icon: PropTypes.any,
        size: PropTypes.string,
        animation: PropTypes.string,
        color: PropTypes.string,
        disabled: PropTypes.bool

    }

    static defaultProps = {
        account: null,
        color: 'primary',
        animation: 'grow',
        size: 'sm',
        icon: (<div className='.icon'/>),
        text: ('Send Transaction'),
        onSubmission: () => {},
        onResult: () => {},
        onReceipt: () => {},
        onError: () => {},
        disabled: false
    }

    submitTransaction(e) {
        e.preventDefault();
        const { sendTransaction, account, onSubmission, onReceipt, onResult, onError } = this.props;
        try{
            sendTransaction.estimateGas({ from: account }).then((estimatedGas) => {
                this.setState({ txWaiting: true });
                sendTransaction.send({
                    from: account,
                    gasLimit: estimatedGas
                }).once('transactionHash', (txHash) => {
                    onSubmission(txHash);
                }).once('receipt', (receipt) =>{
                    onReceipt(receipt);
                }).then((result) => {
                    onResult(result);
                }).catch((error) => {
                    onError(error);
                }).finally(() => {
                    this.setState({ txWaiting: false });
                });
            }).catch((error) => {
                onError(error);
            });
        } catch(error) {
            onError(error);
        }
        
    }

    render() {
        const { txWaiting } = this.state;
        const { size, color, account, text, icon, animation, disabled } = this.props;
        return (
            <Button
                outline={txWaiting}
                type='submit' 
                size={size}
                color={color} 
                disabled={(disabled || txWaiting || !account)}
                onClick={(e) => this.submitTransaction(e)}>
                {text}
                {txWaiting ? 
                    <Spinner size={size} type={animation} color={color} />
                    :
                    icon }
            </Button>
        )
    }
}

export default TransactionSubmitButton;