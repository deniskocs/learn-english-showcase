export default class PlainTextForm {
    constructor(onAnalyze) {
        this.onAnalyze = onAnalyze

        const container = document.createElement("div")

        // --- Текст для анализа ---
        const textGroup = document.createElement("div")
        textGroup.className = "mb-3"

        const textLabel = document.createElement("label")
        textLabel.htmlFor = "textInput"
        textLabel.className = "form-label fw-semibold"
        textLabel.textContent = "Текст для анализа"

        const textArea = document.createElement("textarea")
        textArea.className = "form-control"
        textArea.id = "textInput"
        textArea.placeholder = "Вставьте сюда английский текст..."
        textArea.style.height = "200px"

        textGroup.appendChild(textLabel)
        textGroup.appendChild(textArea)
        container.appendChild(textGroup)

        // --- Минимум повторений ---
        const row = document.createElement("div")
        row.className = "row g-3 align-items-center"

        const colLabel = document.createElement("div")
        colLabel.className = "col-auto"

        const minLabel = document.createElement("label")
        minLabel.htmlFor = "minOccurrences"
        minLabel.className = "col-form-label fw-semibold"
        minLabel.textContent = "Минимум повторений слова:"
        colLabel.appendChild(minLabel)

        const colSelect = document.createElement("div")
        colSelect.className = "col-auto"

        const select = document.createElement("select")
        select.id = "minOccurrences"
        select.className = "form-select"
        for (let i = 1; i <= 4; i++) {
            const option = document.createElement("option")
            option.value = i
            option.textContent = `${i} раз`
            select.appendChild(option)
        }
        colSelect.appendChild(select)

        const colButton = document.createElement("div")
        colButton.className = "col-auto ms-auto"

        const button = document.createElement("button")
        button.className = "btn btn-primary"
        button.textContent = "Анализировать текст"
        button.onclick = () => {
            if (this.onAnalyze) {
                this.onAnalyze({
                    text: textArea.value,
                    minOccurrences: parseInt(select.value)
                })
            }
        }
        colButton.appendChild(button)

        row.appendChild(colLabel)
        row.appendChild(colSelect)
        row.appendChild(colButton)

        container.appendChild(row)

        this.item = container
        return this.item
    }
}
