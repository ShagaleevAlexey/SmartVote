<template>
    <section class="container vote-id">
        <div class="slds-grid slds-grid_vertical">


            <div class="slds-grid slds-m-top_large">
                <button class="slds-button slds-button_outline-brand" @click="start()" v-if="isOwner && state == 0">Начать голосование</button>
                <button class="slds-button slds-button_outline-brand" @click="finish()" v-if="isOwner && state == 1">Завершить голосование</button>
            </div>

            <a v-bind:href="'https://rinkeby.etherscan.io/address/' + this.owner" target="_blank">owner: {{ owner }}</a>
            

            <div class="slds-split-view__list-header slds-grid vote-id__question">
                <b><span>{{vote[1]}}</span></b>
                <span class="slds-assistive-text">- Descending</span>
            </div>
            <ul class="slds-scrollable_y">
                <li class="slds-split-view__list-item" v-for="(item, id) in vote[2]" :key="id">
                    <a href="javascript:void(0);" :aria-selected="id == selected" class="slds-split-view__list-item-action slds-grow slds-has-flexi-truncate" @click="onSelect(id)">
                        <div class="slds-grid slds-wrap">
                            <span class="slds-text-body_regular slds-text-color_default">{{convertFromHex(item)}}</span>
                            <span class="slds-col_bump-left" title="74">{{vote[3][id]}}</span>
                        </div>
                    </a>
                </li>
            </ul>
        </div>
        <div class="slds-grid slds-grid_align-center slds-m-top_large">
            <button class="slds-button slds-button_outline-brand" @click="onConfirm()" v-if="state == 1">Подтвердить выбор</button>
        </div>
    </section>
</template>

<script>
    import {fromHex} from '../../util/strHex.js';
    export default {
        data() {
            return {
                selected: null,
                vote: {},
                owner: undefined,
                state: undefined,
                isOwner: undefined
            };
        },
        mounted() {
            this.getVote();
            this.getOwner();
        },
        methods: {
            getVote() {
                let self = this
                var contractInstance = this.$store.state.voteFactory.contractInstance
                var voteId = this.$route.params.id
                if(contractInstance != undefined) {
                    contractInstance.methods.getVote(voteId).call()
                    .then(function(res){
                        console.log(res)
                        self.vote = res;
                        self.state = res[0]
                    })
                    .catch(function(err) {
                        console.log(err)
                    });
                }
            },
            getOwner() {
                let self = this
                var web3 = this.$store.state.web3.web3Instance
                var contractInstance = this.$store.state.voteFactory.contractInstance
                var account = this.$store.state.account.address
                var voteId = this.$route.params.id
                    if(contractInstance != undefined) {
                    contractInstance.methods.voteToOwner(voteId).call()
                    .then(function(res){
                        self.owner = res;
                        if(web3.utils.toChecksumAddress(res) == web3.utils.toChecksumAddress(account)) {
                            self.isOwner = true
                        }
                        else {
                            self.isOwner = false
                        }
                    })
                    .catch(function(err) {
                        console.log(err)
                        self.owner = '';
                    });
                }
            },
            onSelect(id) {
                this.selected = id;
            },
            onConfirm() {
                console.log('haha')
                var contractInstance = this.$store.state.voteFactory.contractInstance
                var account = this.$store.state.account.address
                var voteId = this.$route.params.id
                var selectId = this.selected
                if (account == undefined || selectId == null) {
                    console.log('need login and select answer')
                }
                else {
                    contractInstance.methods.cast(voteId, selectId).send({
                        from: account,
                        gas: 1500000
                    }, function(error, result){
                        if(error) {
                            console.log(error)
                        }
                        else {
                            console.log(result)
                        }
                    });
                }
            },
            convertFromHex: function(str) {
                var res = fromHex(str.substr(2), '')
                return res
            },
            start() {
                var contractInstance = this.$store.state.voteFactory.contractInstance
                var account = this.$store.state.account.address
                var voteId = this.$route.params.id
                contractInstance.methods.startVote(voteId).send({
                    from: account,
                    gas: 1500000
                }, function(error, result){
                    if(error) {
                        console.log(error)
                    }
                    else {
                        console.log(result)
                    }
                });
            },
            finish() {
                var contractInstance = this.$store.state.voteFactory.contractInstance
                var account = this.$store.state.account.address
                var voteId = this.$route.params.id
                contractInstance.methods.stopVote(voteId).send({
                    from: account,
                    gas: 1500000
                }, function(error, result){
                    if(error) {
                        console.log(error)
                    }
                    else {
                        console.log(result)
                    }
                });
            }
        }
    };
</script>

<style lang="scss">
    .vote-id {
        margin: 4rem auto;
        &__question {
            border-top: none;
        }
    }
</style>