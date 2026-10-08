export default function Progress(value, max = 6) {
    const percent = Math.min(100, Math.round((value / max) * 100))
  
    const progressDiv = document.createElement("div")
    progressDiv.className = "progress"
    progressDiv.style.height = "8px"
  
    const progressBar = document.createElement("div")
    progressBar.className = "progress-bar bg-success"
    progressBar.style.width = `${percent}%`
  
    progressDiv.appendChild(progressBar)
    return progressDiv
}
  