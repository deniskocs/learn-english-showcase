import CardContainer from "../components/CardContainer.js";
import PlainTextForm from "./PlainTextForm.js";
import Loader from "../components/Loader.js";
import AnalysisResult from "./AnalysisResult.js";

export default class TextAnalyzer {
    constructor(model) {
        this.model = model
        this.model.view = this
        this.item = document.createElement("div")
        this.resultContainer = document.createElement("div")
        
        const textAnalyzer = CardContainer(new PlainTextForm((item) => this.analyze(item)))
        this.item.append(textAnalyzer)
        this.item.append(this.resultContainer)
        
        this.render()
        return this.item
    }
    
    render() {
        this.resultContainer.innerHTML = ""
    
        if (this.model.data !== null){
            try {
                this.resultContainer.append(new CardContainer(new AnalysisResult(this.model)))
            } catch (e) {
                console.error("Failed to show analysis result", e)
                const error = document.createElement("div")
                error.className = "alert alert-danger"
                error.textContent = "Не удалось отобразить результат анализа"
                this.resultContainer.append(error)
            }
        } else if (this.model.inProgress) {
            this.resultContainer.append(new CardContainer(new Loader()))
        }
    }

    analyze(item) {
        this.model.analyze(item.text, item.minOccurrences)
    }
}