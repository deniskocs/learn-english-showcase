export default function ErrorPlaceholder(onRetry) {
    const wrapper = document.createElement("div")
    wrapper.className = "d-flex flex-column justify-content-center align-items-center p-5 border rounded bg-white"

    const title = document.createElement("div")
    title.className = "text-danger fw-bold mb-2"
    title.textContent = "Ошибка загрузки"

    const subtitle = document.createElement("div")
    subtitle.className = "text-muted mb-3"
    subtitle.textContent = "Не удалось получить данные"

    const btn = document.createElement("button")
    btn.className = "btn btn-primary btn-sm"
    btn.textContent = "Перезапросить"
    btn.onclick = onRetry

    wrapper.appendChild(title)
    wrapper.appendChild(subtitle)
    wrapper.appendChild(btn)

    return wrapper
}
