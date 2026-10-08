class DictionaryModel {
    constructor(networkService) {
        this.userInfo = null
        this.networkService = networkService
    }

    loadData() {
        let request = {
            endpoint: "getInfo",
            method: "GET"
        }

        this.networkService.send(request, (data) => {
            this.userInfo = data
            this.view.reload()
        })
    }
}

export default DictionaryModel