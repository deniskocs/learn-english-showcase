import DictionaryHeader from "./DictionaryHeader.js";
import Progress from "../components/Progress.js";
import UnknownWordsContainer from './UnknownWordsContainer.js'
import UnknownWordsModel from './UnknownWordsModel.js'
import ActiveWordsModel from './ActiveWordsModel.js'
import ActiveWordsContainer from './ActiveWordsContainer.js'
import KnownWordsContainer from './KnownWordsContainer.js'
import KnownWordsModel from './KnownWordsModel.js'
import { track } from "../Analytics.js";

class DictionaryView {
  constructor(model) {
    this.model = model
    this.model.view = this

    this.newWordsContainerModel = new UnknownWordsModel(model.networkService)
    this.newWordsContainer = new UnknownWordsContainer(this.newWordsContainerModel);

    this.activeWordsModel = new ActiveWordsModel(model.networkService)
    this.activeWordsContainer = new ActiveWordsContainer(this.activeWordsModel);

    this.knownWordsModel = new KnownWordsModel(model.networkService)
    this.knownWordsContainer = new KnownWordsContainer(this.knownWordsModel);

    this.tabNames = [
      { id: "new", title: "Новые слова", content: this.newWordsContainer.item },
      { id: "learning", title: "В обучении", content: this.activeWordsContainer.item },
      { id: "known", title: "Известные слова", content: this.knownWordsContainer.item }
    ]


    this.item = document.createElement("div")
    this.item.className = "vocabulary-container mx-auto px-4 mt-4"
    this.reload()
    return this.item
  }

  onSearch(query) {
    if (this.model.filterByQuery) this.model.filterByQuery(query)
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
      button.addEventListener("shown.bs.tab", () => {
        track("tab_viewed", { tab: tab.id })
      })
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

  reload() {
    this.item.innerHTML = ""
    if (this.model.userInfo == null) {
      this.item.append(new Progress())
      return
    }

    // Заголовок
    this.header = new DictionaryHeader(
      "Управляйте словами, которые вы изучаете",
      this.model.userInfo.trainedWordsCount,
      this.model.userInfo.wordsCount,
      (query) => this.onSearch(query)
    )
    this.item.append(this.header.item)

    this.item.append(this.createContent())
  }
}

export default DictionaryView
