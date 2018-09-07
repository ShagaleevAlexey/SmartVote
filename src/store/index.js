import Vue from 'vue'
import Vuex from 'vuex'
import web3 from '~/plugins/web3'
import VoteFactory from '../../build/contracts/VoteFactory'
import getWeb3 from '../util/getWeb3'
import pollWeb3 from '../util/poolWeb3'

Vue.use(Vuex)

// const voteFactoryAddress = '0x86ba28d49473f11ce297a5cfee29a0370d1fccb1'
// const voteFactoryContract = new web3.eth.Contract(VoteFactory.abi, voteFactoryAddress)

// let account
// web3.eth.getAccounts().then(res => {
//   account = res[0]
// })

const store = () => new Vuex.Store({
  state: {
    web3: {
      web3Instance: undefined,
      isInjected: false,
      networkId: undefined,
      error: undefined
    },
    voteFactory: {
      address: '0xd3fffe215c1c27c1c61ae3f4b904c0e9eab5aeed',
      contractInstance: undefined
    },
    account: {
      address: undefined,
      balance: undefined
    }
  },
  mutations: {
    registerWeb3(state, payload) {
      let web3 = payload.web3()
      let isInjected = payload.isInjected
      let networkId = payload.networkId

      state.web3 = {
        web3Instance: web3,
        isInjected: isInjected,
        networkId: networkId,
        error: undefined
      }
      pollWeb3(this)
    },
    registerVoteFactory(state, payload) {
      state.voteFactory.contractInstance = new state.web3.web3Instance.eth.Contract(VoteFactory.abi, state.voteFactory.address)
    },
    updateAccount(state, payload) {
      state.account.address = payload.coinbase
      state.account.balance = payload.balance
    }
  },
  actions: {
    registerWeb3 ({commit}) {
      console.log('\'registerWeb3\' action being executed')
      getWeb3.then(result => {
        console.log('committing result to \'registerWeb3\' mutation')

        commit('registerWeb3', result)
        commit('registerVoteFactory')
        commit('updateAccount', result)
      }).catch(e => {
        console.log('error in action \'registerWeb3\'', e)
      })
    },
    updateAccount ({commit}, payload) {
      commit('updateAccount', payload)
    }
  }
})

export default store
