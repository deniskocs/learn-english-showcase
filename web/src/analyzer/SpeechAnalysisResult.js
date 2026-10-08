import CardContainer from "../components/CardContainer.js"
import Loader from "../components/Loader.js"
import EmptyBody from "../components/EmptyBody.js"

export default class SpeechAnalysisResult {
    constructor(model) {
        this.model = model
        this.item = document.createElement("div")
        this.item.className = "speech-analysis-result mt-3"
        this.render()
        return this.item
    }

    buildContent() {
        const content = document.createElement("div")
        
        if (this.model.inProgress) {
            content.appendChild(Loader())
            return content
        }

        if (this.model.data === null) {
            const emptyMessage = document.createElement("div")
            emptyMessage.className = "text-center text-muted py-3"
            emptyMessage.textContent = "Нет данных для отображения"
            content.appendChild(emptyMessage)
            return content
        }

        const data = this.model.data

        // Заголовок раздела
        const title = document.createElement("h5")
        title.className = "fw-semibold mb-3"
        title.textContent = "Результаты анализа"
        content.appendChild(title)

        // Refined Text (исправленный текст)
        if (data.refinedText) {
            const refinedSection = this.buildSection("Исправленный текст", data.refinedText)
            content.appendChild(refinedSection)
        }

        // English Text (английский текст)
        if (data.englishText) {
            const englishSection = this.buildSection("Английский текст", data.englishText)
            content.appendChild(englishSection)
        }

        // Description (описание)
        if (data.description) {
            const descSection = this.buildSection("Описание", data.description)
            content.appendChild(descSection)
        }

        return content
    }

    buildSection(title, text) {
        const section = document.createElement("div")
        section.className = "mb-4"

        const sectionTitle = document.createElement("h6")
        sectionTitle.className = "fw-semibold mb-2 text-secondary"
        sectionTitle.textContent = title
        section.appendChild(sectionTitle)

        const sectionText = document.createElement("div")
        sectionText.className = "p-3 bg-light rounded"
        sectionText.style.cssText = `
            white-space: pre-wrap;
            word-wrap: break-word;
            line-height: 1.6;
        `
        sectionText.textContent = text
        section.appendChild(sectionText)

        return section
    }

    render() {
        this.item.innerHTML = ""
        this.item.appendChild(this.buildContent())
    }
}

