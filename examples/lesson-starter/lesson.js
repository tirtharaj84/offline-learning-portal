const button = document.querySelector("#show-answer");
const answer = document.querySelector("#answer");
button.addEventListener("click", () => {
  answer.hidden = !answer.hidden;
  button.textContent = answer.hidden
    ? "Show answer"
    : "Hide answer";
});
