document.querySelector('.js-confirm').addEventListener('submit', (ev) => {
  let username =  document.querySelector('.js-confirm input[type=hidden]').getAttribute('value');
  let prompt = `⚠️ Achtung ⚠️\n
Diese Action wird deinen Account sofort vollständig löschen.\n
Das kann nicht rückgängig gemacht werden.\n
Bestätige die Löschung mit deinem Username ${username} `;
  let answer = window.prompt(prompt);

  if (answer === username) {
    return true;
  } else {
    ev.preventDefault();
    return false;
  }
});
