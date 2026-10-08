export default function Loader() {
    const loader = document.createElement("div")
    loader.className = "d-flex justify-content-center align-items-center py-5"
  
    const spinner = document.createElement("div")
    spinner.className = "spinner-border text-primary"
    spinner.style.width = "4rem"
    spinner.style.height = "4rem"
    spinner.setAttribute("role", "status")
  
    const span = document.createElement("span")
    span.className = "visually-hidden"
    span.textContent = "Загрузка..."
  
    spinner.appendChild(span)
    loader.appendChild(spinner)
    return loader
  }
  