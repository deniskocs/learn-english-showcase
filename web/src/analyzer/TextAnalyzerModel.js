export default class TextAnalyzerModel {
    constructor(networkService) {
        this.networkService = networkService
        this.inProgress = false
        this.data = null
        this.view = null
    }

    analyze(text, minimalRepeatNumber) {
        this.inProgress = true
        this.data = null
        this.view.render()

        let request = {
            endpoint: "parse",
            isJson: true,
            body: JSON.stringify({
                text: text,
                minimalRepeatNumber: minimalRepeatNumber
            }),
            method: "POST"
        }

        this.networkService.send(request, (data) => {
            this.inProgress = false
            this.data = normalizeParseResponse(data)
            this.view.render()
        })
    }

    markDefinitionAsTrained(index, word, id) {
      this.networkService.markDefinitionAsTrained(word, id, this.remove.bind(this, index))
    }
  
    trainDefinition(index, word, id) {
      this.networkService.trainDefinition(word, id, this.remove.bind(this, index))
    }
  
    removeDefinition(index, word, id) {  
      this.networkService.removeDefinition(word, id, this.remove.bind(this, index))
    }

    markAnalyzedWordKnown(index, wordId) {
      this.networkService.markVocabularyWordKnown(wordId, this.removeAnalyzedWord.bind(this, index))
    }

    trainAnalyzedWord(index, wordId) {
      this.networkService.trainVocabularyWord(wordId, this.removeAnalyzedWord.bind(this, index))
    }

    remove(index) {
        this.data.legacy.splice(index, 1)
        this.view.render()
    }

    removeAnalyzedWord(index) {
        this.data.analysis.words.splice(index, 1)
        this.view.render()
    }

    removeWordsWithoutMeanings() {
        if (!this.data || !Array.isArray(this.data.legacy)) {
            return
        }
        this.data.legacy = this.data.legacy.filter(word => word.meanings && word.meanings.length > 0)
    }
}

function normalizeParseResponse(data) {
    if (data == null) {
        return { legacy: [], analysis: { words: [] } }
    }
    if (Array.isArray(data)) {
        return { legacy: data, analysis: { words: [] } }
    }
    const words = Array.isArray(data.analysis?.words)
        ? data.analysis.words
        : Array.isArray(data.analysis)
            ? data.analysis
            : []
    return {
        legacy: Array.isArray(data.legacy) ? data.legacy : [],
        analysis: { words }
    }
}