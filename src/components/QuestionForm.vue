<template>
  <div class="slds-form slds-form_stacked">
    <div class="slds-form-element">
      <div class="slds-form-element__control">
        <textarea id="textarea-id-01" class="slds-textarea" placeholder="Enter question" v-model="model.question"></textarea>
      </div>
    </div>
    <div class="slds-form-element">
      <div class="slds-form-element__control">
        <input type="text" id="text-input-id-1" class="slds-input" placeholder="Enter answer" v-model="answers_a[0]" maxlength="32" />
      </div>
    </div>
    <div class="slds-form-element">
      <div class="slds-form-element__control">
        <input type="text" id="text-input-id-1" class="slds-input" placeholder="Enter answer" v-model="answers_a[1]" maxlength="32" />
      </div>
    </div>
    <div class="slds-form-element" v-for="(answer, key) in answers_b" :key="key">
      <div class="slds-form-element__control">
        <input type="text" id="text-input-id-1" class="slds-input" placeholder="Enter answer" v-model="answers_b[key]" maxlength="32" />
      </div>
    </div>
    <div class="slds-form-element">
      <div class="slds-grid slds-grid_align-spread">
        <button class="slds-button slds-button_success" @click="onNewAnswer()">+ more answers</button>
        <button class="slds-button slds-button_brand" :disabled="validate()" @click="onCreate()">Create</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      answers_a: [],
      answers_b: [],
      model: {
        question: "",
        answers: []
      }
    };
  },
  watch: {
    answers_a(value) {
      this.mergeAnswers();
    },
    answers_b(value) {
      this.mergeAnswers();
    }
  },
  methods: {
    validate() {
      if (this.model.question.length && this.model.answers.length >= 2) {
        return false;
      }
      return true;
    },
    mergeAnswers() {
      let answers = this.answers_a.concat(this.answers_b);
      this.model.answers = answers.filter(val => val);
    },
    onNewAnswer() {
      this.answers_b.push("");
    },
    onCreate() {
      this.$emit('create', this.model);
    }
  }
};
</script>

