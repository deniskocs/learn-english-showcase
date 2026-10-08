const State = {
    loading: () => ({ type: 'loading' }),
    error: (errorCode) => ({ type: 'error', errorCode }),
    data: (recordings) => ({ type: 'data', recordings })
}

class SpeechAnalysisModel {
    constructor(networkService) {
        this.networkService = networkService
        this.view = null
        this.state = State.loading()
        this.recordings = []
    }

    loadData() {
        this.state = State.loading()
        if (this.view && this.view.reload) this.view.reload()

        const request = {
            endpoint: "recordings",
            method: "GET"
        }

        this.networkService.send(request, (data) => {
            // Преобразуем данные из API в формат для карточек
            const recordings = (data.recordings || []).map(recording => ({
                id: recording.uuid,
                uuid: recording.uuid,
                title: recording.title || `Анализ записи от ${this.formatDate(recording.time)}`,
                description: recording.description || "Описание отсутствует",
                status: recording.status,
                time: recording.time,
                englishText: recording.englishText,
                refinedText: recording.refinedText
            }))
            this.state = State.data(recordings)
            if (this.view && this.view.reload) this.view.reload()
        }, (errorCode) => {
            this.state = State.error(errorCode)
            if (this.view && this.view.reload) this.view.reload()
        })
    }

    formatDate(timestamp) {
        if (!timestamp) return "неизвестная дата"
        const date = new Date(timestamp)
        const day = String(date.getDate()).padStart(2, '0')
        const month = String(date.getMonth() + 1).padStart(2, '0')
        const year = date.getFullYear()
        return `${day}.${month}.${year}`
    }

    deleteRecording(uuid, onSuccess, onError) {
        const request = {
            endpoint: "deleteRecording",
            params: `uuid=${uuid}`,
            method: "POST"
        }

        this.networkService.send(request, (data) => {
            // После успешного удаления перезагружаем данные
            this.loadData()
            if (onSuccess) onSuccess(data)
        }, (errorCode) => {
            if (onError) onError(errorCode)
        })
    }
}

export default SpeechAnalysisModel
export { State }

