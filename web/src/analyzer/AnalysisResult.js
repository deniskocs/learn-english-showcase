import WordContextRow from "./WordContextRow.js";
import AnalyzedWordRow from "./AnalyzedWordRow.js";
import UnknownWordDetailsModalModel from "../dictionary/UnknownWordDetailsModalModel.js";
import WordDetailsModal from "../components/WordDetailsModal.js";
import EmptyBody from "../components/EmptyBody.js";

export default class AnalysisResult {
    constructor(model) {
      this.model = model
      this.item = document.createElement("div")
      try {
        if (this.model.removeWordsWithoutMeanings) {
          this.model.removeWordsWithoutMeanings()
        }
        this.item.appendChild(this.buildContent())
      } catch (e) {
        console.error("Failed to render analysis result", e)
        const error = document.createElement("div")
        error.className = "alert alert-danger mb-0"
        error.textContent = "Не удалось отобразить результат анализа"
        this.item.appendChild(error)
      }
      return this.item
    }
  
    buildMultipleDefinitionsRow(item) {
      return WordContextRow({
        word: item,
        light: {
          name: "Варианты",
          onPress: () => this.showDetails(item) 
        }
      })
    }
  
    buildDefinitionRow(index, item) {
      const word = item.word, id = item.meanings[0].meaningId
      return WordContextRow({
        word: item,
        primary: {
          name: "Знаю",
          onPress: () => this.markDefinitionAsTrained(index, word, id) 
        },
        secondary: {
          name: "Учить",
          onPress: () => this.trainDefinition(index, word, id) 
        },
        delete: {
          name: "Удалить",
          onPress: () => this.removeDefinition(index, word, id) 
        }  
      })
    }
  
    buildWordRows(words) {
      const tbody = document.createElement("tbody")
      if (!Array.isArray(words)) {
        return tbody
      }
      words.forEach((item, index) => {
        const meanings = item.meanings || []
        if (meanings.length > 1) {
          tbody.appendChild(this.buildMultipleDefinitionsRow(item))
        } else if (meanings.length === 1) {
          tbody.appendChild(this.buildDefinitionRow(index, item))
        } else {
          tbody.appendChild(WordContextRow({ word: item }))
        }
      })
      return tbody
    }
  
    buildSectionTitle(text) {
      const title = document.createElement("h5")
      title.className = "fw-semibold mb-3"
      title.textContent = text
      return title
    }
  
    buildHeader(columns) {
      const thead = document.createElement("thead")
      const row = document.createElement("tr")
      columns.forEach((column) => {
        const th = document.createElement("th")
        th.textContent = column.title
        if (column.className) {
          th.className = column.className
        }
        row.appendChild(th)
      })
      thead.appendChild(row)
      return thead
    }

    buildNewWordRows(words) {
      const tbody = document.createElement("tbody")
      if (!Array.isArray(words)) {
        return tbody
      }
      words.forEach((item, index) => {
        tbody.appendChild(AnalyzedWordRow({
          word: item,
          primary: {
            name: "Знаю",
            onPress: () => this.markAnalyzedWordKnown(index, item.id)
          },
          secondary: {
            name: "Учить",
            onPress: () => this.trainAnalyzedWord(index, item.id)
          }
        }))
      })
      return tbody
    }

    buildTable(body, emptyMessage, columns) {
      const table = document.createElement("table")
      table.className = "table table-hover align-middle mb-0"
      const isEmpty = !(body instanceof HTMLElement) || body.childElementCount === 0
      if (isEmpty) {
        table.appendChild(EmptyBody(emptyMessage, columns.length))
      } else {
        table.appendChild(this.buildHeader(columns))
        table.appendChild(body)
      }
      return table
    }

    appendSection(parent, title, buildBody, emptyMessage, columns) {
      parent.appendChild(this.buildSectionTitle(title))
      try {
        parent.appendChild(this.buildTable(buildBody(), emptyMessage, columns))
      } catch (e) {
        console.error(`Failed to render section "${title}"`, e)
        const error = document.createElement("div")
        error.className = "alert alert-warning"
        error.textContent = `Не удалось отобразить секцию «${title}»`
        parent.appendChild(error)
      }
    }

    buildContent() {
      const content = document.createElement("div")
      const newWords = Array.isArray(this.model.data?.analysis?.words)
        ? this.model.data.analysis.words
        : []
      const legacyWords = Array.isArray(this.model.data?.legacy)
        ? this.model.data.legacy
        : []

      this.appendSection(
        content,
        "Новый анализ",
        () => newWords.length > 0 ? this.buildNewWordRows(newWords) : null,
        "Нет слов в новом анализе",
        [{ title: "Слово" }, { title: "Контексты" }, { title: "Действия", className: "text-end" }]
      )

      const legacyDivider = document.createElement("hr")
      legacyDivider.className = "my-4"
      content.appendChild(legacyDivider)

      this.appendSection(
        content,
        "Старый анализ",
        () => legacyWords.length > 0 ? this.buildWordRows(legacyWords) : null,
        "Нет новых слов для изучения",
        [{ title: "Слово" }, { title: "Контексты" }, { title: "Действия", className: "text-end" }]
      )
      return content
    }

    render() {
        if (this.model.removeWordsWithoutMeanings) {
            this.model.removeWordsWithoutMeanings()
        }
        this.item.innerHTML = ""

        this.item.appendChild(this.buildContent())
    }

    showDetails(word) {
        if (word.meanings.length > 1) {
            const modalModel = new UnknownWordDetailsModalModel(
              {
                word: word.word,
                definitions: word.meanings
              },
              this.model.networkService,
              () => this.render()
            )
            const modal = new WordDetailsModal(modalModel)
            document.body.appendChild(modal)
            const modalInstance = new bootstrap.Modal(modal)
            modalInstance.show()
        }
    }

    markAnalyzedWordKnown(index, wordId) {
        this.model.markAnalyzedWordKnown(index, wordId)
    }

    trainAnalyzedWord(index, wordId) {
        this.model.trainAnalyzedWord(index, wordId)
    }

    markDefinitionAsTrained(index, word, id) {
        console.log(word, id)
        this.model.markDefinitionAsTrained(index, word, id)
    }

    trainDefinition(index, word, id) {
        console.log(word, id)
        this.model.trainDefinition(index, word, id)
    }

    removeDefinition(index, word, id) {
        console.log(word, id)
        this.model.removeDefinition(index, word, id)
    }
  }
  