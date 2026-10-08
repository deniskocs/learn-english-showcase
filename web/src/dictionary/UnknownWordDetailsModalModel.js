import { track } from "../Analytics.js";

class UnknownWordDetailsModalModel {
  constructor(word, networkService, reload) {
    this.view = null  
    this.word = word
    this.definitions = word.definitions
    this.networkService = networkService
    this.reload = reload
  }

  rowModel(index, definition) {
    return {
      word: definition,
      primary: {
        name: "Знаю",
        onPress: (rowItem, button) => this.markDefinitionAsTrained(index, definition, button) 
      },
      secondary: {
        name: "Учить",
        onPress: (rowItem, button) => this.trainDefinition(index, definition, button) 
      },
      delete: {
        name: "Удалить",
        onPress: (rowItem, button) => this.removeDefinition(index, definition, button) 
      }
    }
  }
  
  trainDefinition(index, definition, button) {
    console.log(definition)
    button.displayLoading()
    this.networkService.trainDefinition(
      definition.word, 
      definition.meaningId, 
      () => {
        button.reset()
        this.definitions.splice(index, 1)
        this.closeOrRender()
        track("word_added_to_learning", { word_id: definition.word, sense_id: definition.meaningId, source_tab: "new", dialog: true })
      },
      () => {
        button.displayError()
      }
    )
  }
  
  markDefinitionAsTrained(index, definition, button) {
    console.log(definition)
    button.displayLoading()
    this.networkService.markDefinitionAsTrained(
      definition.word, 
      definition.meaningId, 
      () => {
        button.reset()
        this.definitions.splice(index, 1)
        this.closeOrRender()
        track("word_marked_known", { word_id: definition.word, sense_id: definition.meaningId, source_tab: "new", dialog: true })
      },
      () => {
        button.displayError()
      }
    )
  }
  
  removeDefinition(index, definition, button) {
    console.log(definition)
    button.displayLoading()
    this.networkService.removeDefinition(
      definition.word, 
      definition.meaningId, 
      () => {
        button.reset()
        this.definitions.splice(index, 1)
        this.closeOrRender()
        track("word_deleted", { word_id: this.word.word, sense_id: definition.meaningId, source_tab: "new", dialog: true })
      },
      () => {
        button.displayError()
      }
    )
  }

  closeOrRender() {
    if (this.definitions.length === 0) {
        track("modal_closed", { modal: "word_details", reason: "no_items_left" })
        this.view.close()
    } else {
        this.view.render()
    }
  }
}

export default UnknownWordDetailsModalModel