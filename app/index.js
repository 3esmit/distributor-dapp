import EmbarkJS from '../embarkArtifacts/embarkjs';
import React from 'react';
import ReactDOM from 'react-dom';
import classnames from 'classnames';
import {TabContent, TabPane, Navbar, Nav, NavItem, NavLink, NavbarBrand, NavbarToggler, Collapse} from 'reactstrap';
import Ethereum from './js/Ethereum';
import Account from './js/Account';
//import './css/dapp.css';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      blockchainEnabled: false,
      accounts: [],
      strError: "",
      activeKey: '1',
      latestBlock: null
    };
  }

  componentDidMount() {

  }

  handleSelect(key) {
    this.setState({activeKey: key});
  }

  onBlockUpdate(latestBlock){
    this.setState({ latestBlock })
  }

  onAccountChange(accounts ) {
    this.setState({ accounts })
  }

  render() {
    const {accounts, latestBlock, activeKey, toggle} = this.state;
    return (
    <React.Fragment>
      <div id="header">
        <Navbar color="faded" light>
          <NavbarBrand href="/" className="mr-auto">My Governance Example</NavbarBrand>
          <NavbarToggler onClick={()=> this.setState({toggle: !toggle})} className="mr-2" />
            <Collapse isOpen={!toggle} navbar>
              <Nav vertical>
                <NavItem>
                  <Account onChange={(accounts) => this.onAccountChange(accounts)}/>
                </NavItem>
              </Nav>
          </Collapse>
        </Navbar>
      </div>
      <div id="main">

      </div>
      <div id="footer">

        <Ethereum onBlockUpdate={(latestBlock) => this.onBlockUpdate(latestBlock)}/>
      </div>
    </React.Fragment>);
  }
}

ReactDOM.render(<App></App>, document.getElementById('app'));