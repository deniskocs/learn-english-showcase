import SpeechAnalysisCard from "../components/SpeechAnalysisCard.js"
import Loader from "../components/Loader.js"
import ErrorPlaceholder from "../components/ErrorPlaceholder.js"
import AnalysisResult from "./AnalysisResult.js"
import CardContainer from "../components/CardContainer.js"
import TextAnalyzerModel from "./TextAnalyzerModel.js"

export default class SpeechAnalysisView {
    constructor(model) {
        this.model = model
        this.model.view = this
        this.item = document.createElement("div")
        this.openResults = new Map() // Map<uuid, {card, resultModel, resultView}>
        this.model.loadData()
        this.render()
        return this.item
    }

    handleDelete(data) {
        // Закрываем результаты если они открыты
        if (this.openResults.has(data.uuid)) {
            this.closeResults(data.uuid)
        }
        
        this.model.deleteRecording(
            data.uuid,
            () => {
                console.log("Запись успешно удалена")
            },
            (errorCode) => {
                console.error("Ошибка при удалении записи:", errorCode)
            }
        )
    }

    handleCardClick(recording, isHighlighted) {
        if (isHighlighted) {
            // Открываем результаты
            this.showResults(recording)
        } else {
            // Закрываем результаты
            this.closeResults(recording.uuid)
        }
    }

    showResults(recording) {
        if (this.openResults.has(recording.uuid)) {
            return // Уже открыто
        }

        // Используем TextAnalyzerModel напрямую
        const analysisModel = new TextAnalyzerModel(this.model.networkService)

        // Создаем контейнер для результатов
        const resultContainer = document.createElement("div")
        resultContainer.className = "speech-analysis-result-container"

        // Блоки с полным текстом (English + Russian) рендерятся один раз
        const textBlocksContainer = document.createElement("div")
        textBlocksContainer.append(new CardContainer(this.buildTextBlocks(recording)))

        // Контейнер для найденных незнакомых слов (обновляется через render)
        const wordsContainer = document.createElement("div")

        // Создаем view для результатов (аналогично TextAnalyzer)
        const resultView = {
            render: function() {
                wordsContainer.innerHTML = ""
                if (analysisModel.data !== null) {
                    wordsContainer.append(new CardContainer(new AnalysisResult(analysisModel)))
                } else if (analysisModel.inProgress) {
                    wordsContainer.append(new CardContainer(Loader()))
                }
            }
        }

        analysisModel.view = resultView

        resultContainer.appendChild(textBlocksContainer)
        resultContainer.appendChild(wordsContainer)

        // Находим карточку в DOM и вставляем результаты после неё
        const cardElement = this.item.querySelector(`[data-uuid="${recording.uuid}"]`)
        if (cardElement) {
            cardElement.parentNode.insertBefore(resultContainer, cardElement.nextSibling)
        }

        // Сохраняем ссылки
        this.openResults.set(recording.uuid, {
            card: cardElement,
            analysisModel: analysisModel,
            resultView: resultView,
            resultContainer: resultContainer
        })

        // Получаем английский текст из записи
        const englishText = recording.englishText

        if (!englishText) {
            // Если английского текста нет, показываем сообщение об ошибке
            const errorMessage = document.createElement("div")
            errorMessage.className = "text-center text-muted py-3"
            errorMessage.textContent = "Английский текст отсутствует для данной записи"
            wordsContainer.innerHTML = ""
            wordsContainer.appendChild(errorMessage)
            return
        }

        // Показываем loader для блока со словами
        resultView.render()

        // Отправляем запрос на анализ английского текста
        analysisModel.analyze(englishText, 1)
    }

    buildTextBlocks(recording) {
        const container = document.createElement("div")

        const englishSection = this.buildTextSection("English", recording.englishText)
        if (englishSection) container.appendChild(englishSection)

        const russianSection = this.buildTextSection("Russian", recording.refinedText)
        if (russianSection) container.appendChild(russianSection)

        return container
    }

    buildTextSection(title, text) {
        if (!text) return null

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

    closeResults(uuid) {
        const opened = this.openResults.get(uuid)
        if (opened) {
            // Удаляем контейнер результатов из DOM
            if (opened.resultContainer && opened.resultContainer.parentNode) {
                opened.resultContainer.parentNode.removeChild(opened.resultContainer)
            }
            this.openResults.delete(uuid)
        }
    }

    render() {
        this.item.innerHTML = ""
        // Закрываем все открытые результаты
        this.openResults.clear()

        if (this.model.state.type === 'loading') {
            this.item.appendChild(Loader())
        } else if (this.model.state.type === 'error') {
            this.item.appendChild(ErrorPlaceholder(() => this.model.loadData()))
        } else if (this.model.state.type === 'data') {
            const cardsContainer = document.createElement("div")
            cardsContainer.id = "analysisCards"

            if (this.model.state.recordings.length === 0) {
                const emptyMessage = document.createElement("div")
                emptyMessage.className = "text-center text-muted py-5"
                emptyMessage.textContent = "Нет записей для отображения"
                cardsContainer.appendChild(emptyMessage)
            } else {
                this.model.state.recordings.forEach(recording => {
                    const cardWrapper = document.createElement("div")
                    cardWrapper.setAttribute("data-uuid", recording.uuid)
                    
                    const card = new SpeechAnalysisCard(
                        recording,
                        (data) => this.handleDelete(data),
                        (data, isHighlighted) => this.handleCardClick(data, isHighlighted)
                    )
                    cardWrapper.appendChild(card.item)
                    cardsContainer.appendChild(cardWrapper)
                })
            }

            this.item.appendChild(cardsContainer)
        }
    }

    reload() {
        this.render()
    }
}

