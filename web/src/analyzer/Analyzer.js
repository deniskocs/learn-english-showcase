import AnalyzerHeader from "./AnalyzerHeader.js"
import TextAnalyzer from "./TextAnalyzer.js"
import TextAnalyzerModel from "./TextAnalyzerModel.js"
import SpeechAnalysisView from "./SpeechAnalysisView.js"
import SpeechAnalysisModel from "./SpeechAnalysisModel.js"

class Analyzer {
    constructor(networkService) {        
        const textAnalyzerTabModel = new TextAnalyzerModel(networkService)
        const textAnalyzerTab = new TextAnalyzer(textAnalyzerTabModel)
        const speechAnalysisModel = new SpeechAnalysisModel(networkService)
        const speechAnalysisView = new SpeechAnalysisView(speechAnalysisModel)

        this.tabNames = [
          { id: "text", title: "Разбор текста", content: textAnalyzerTab },
          { id: "files", title: "Анализ файлов", content: document.createElement("div") },
          { id: "recordings", title: "Анализ записей", content: speechAnalysisView }
        ]
    
    
        this.item = document.createElement("div")
        this.item.className = "vocabulary-container mx-auto px-4 mt-4"
        this.render()
        return this.item
    }

    createContent() {
        const container = document.createElement("div")
    
        // Вкладки
        const tabs = document.createElement("ul")
        tabs.className = "nav nav-tabs mb-3"
        tabs.role = "tablist"
    
        this.tabNames.forEach((tab, index) => {
          const li = document.createElement("li")
          li.className = "nav-item"
          const button = document.createElement("button")
          button.className = `nav-link ${index === 0 ? "active" : ""}`
          button.id = `${tab.id}-tab`
          button.type = "button"
          button.role = "tab"
          button.dataset.bsToggle = "tab"
          button.dataset.bsTarget = `#${tab.id}`
          button.textContent = tab.title
          li.appendChild(button)
          tabs.appendChild(li)
        })
    
        // Контент вкладок
        const tabContent = document.createElement("div")
        tabContent.className = "tab-content"
    
        this.tabNames.forEach((section, index) => {
          const tabPane = document.createElement("div")
          tabPane.className = `tab-pane fade ${index === 0 ? "show active" : ""}`
          tabPane.id = section.id
          tabPane.role = "tabpanel"
    
          const placeholder = document.createElement("div")
          placeholder.className = "text-center text-muted py-5"
          tabPane.appendChild(section.content)
          
          tabContent.appendChild(tabPane)
        })
    
        container.append(tabs, tabContent)
        return container
      }

      render() {
        this.item.innerHTML = ""

        this.header = new AnalyzerHeader()
        this.item.append(this.header.item)
    
        this.item.append(this.createContent())
      }
}

export default Analyzer