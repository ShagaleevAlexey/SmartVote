<template>
  <section class="container create">
    <h1 class="title">Title</h1>
    <div class="create__process">
      <process-bar :stages="stages" :current="current" />
    </div>
    <div class="create__content">
      <div class="create__form" v-if="current=='create'">
        <div class="slds-grid slds-gutters slds-wrap">
          <div class="slds-col slds-medium-size slds-small-size_1-of-1">
            <question-form @create="onCreate" />
          </div>
        </div>
      </div>
      <div class="create__form" v-if="current=='waiting'">
        <div class="create__waiting">
          <div class="slds-spinner slds-spinner_large">
            <div class="slds-spinner__dot-a"></div>
            <div class="slds-spinner__dot-b"></div>
          </div>
        </div>
        <p class="create__waiting-text">Ожидается подтверждение транзакции. <br>Пожалуйста, подождите</p>
      </div>
    </div>
  </section>
</template>

<script>
import {toHex} from '../util/strHex.js';
import ProcessBar from "~/components/ProcessBar.vue";
import QuestionForm from "~/components/QuestionForm.vue";
import VoteResult from "~/components/VoteResult.vue";

export default {
  components: {
    ProcessBar,
    QuestionForm,
    VoteResult
  },
  data() {
    return {
      current: "create",
      stages: {
        create: {
          title: "Create vote",
          complete: false
        },
        waiting: {
          title: "Votes waiting",
          complete: false
        }
      },
      vote: {}
    };
  },
  methods: {
    onCreate(data) {
      this.vote = {
        question: data.question,
        answers: data.answers,
      };
      this.startTransaction();
    },
    changeStage(stage) {
      this.stages[this.current].complete = true;
      this.current = stage;
    },
    startTransaction() {
      var contractInstance = this.$store.state.voteFactory.contractInstance
      var account = this.$store.state.account.address
      var self = this
      if (account == undefined) {
        console.log('need login')
      }
      else {
        this.changeStage("waiting");
        var answers = [];
        this.vote.answers.forEach(function(item) {
          answers.push('0x' + toHex(item))
        });
        contractInstance.methods.createVote(this.vote.question, answers).send({
          from: account,
          gas: 1500000
        })
        .on('transactionHash', function(hash){
          console.log(hash)
        })
        .on('confirmation', function(confirmationNumber, receipt){
          if(confirmationNumber == 1) {
            console.log(receipt)
            var path = "/vote/" + receipt.events.CreateVote.returnValues.id
            self.changeStage("finish");
            self.$router.replace({ path: path })
          }
        })
        .on('error', function(error) {
          console.log(error)
          document.location.href = "/create"
        })
      }
    }
  }
};
</script>

<style lang="scss">
.create {
  &__process {
    max-width: 50%;
    margin: 4em auto;
    @media (max-width: 768px) {
      max-width: 100%;
    }
  }
  &__content {
    margin: 4em 0;
  }
  &__image {
    text-align: center;
  }
  &__waiting {
    position: relative;
    height: 5rem;
    &-text {
      margin-top: 1rem;
      text-align: center;
    }
  }
}
</style>
