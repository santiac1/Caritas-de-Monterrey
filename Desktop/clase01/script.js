// Simple "hardcoded" users (default). New accounts are saved to localStorage too.
var STORAGE_KEY = "clase01_users_v1";
var SESSION_KEY = "clase01_session_email_v1";

var DEFAULT_USERS = [
  {
    firstName: "Victor",
    lastName: "Valero",
    dob: "2000-01-01",
    email: "test@correo.com",
    password: "1234"
  }
];

function loadUsers() {
  try {
    var raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULT_USERS.slice();
    var parsed = JSON.parse(raw);
    if (!parsed || !parsed.length) return DEFAULT_USERS.slice();
    return parsed;
  } catch (e) {
    return DEFAULT_USERS.slice();
  }
}

function saveUsers(users) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(users));
}

function normalizeEmail(value) {
  return value.replace(/^\s+|\s+$/g, "").toLowerCase();
}

function findUserByEmail(users, email) {
  var i;
  for (i = 0; i < users.length; i++) {
    if (normalizeEmail(users[i].email) === normalizeEmail(email)) return users[i];
  }
  return null;
}

function getOrCreateErrorEl(inputEl) {
  var id = inputEl.id + "-error";
  var el = document.getElementById(id);

  if (!el) {
    el = document.createElement("p");
    el.id = id;
    el.className = "field-error";


    var nextEl = inputEl.nextElementSibling;
    if (nextEl) {
      inputEl.parentNode.insertBefore(el, nextEl);
    } else {
      inputEl.parentNode.appendChild(el);
    }
  }

  return el;
}

function setError(inputEl, message) {
  var el = getOrCreateErrorEl(inputEl);
  el.innerText = message;
  inputEl.classList.add("has-error");
}

function clearError(inputEl) {
  var el = getOrCreateErrorEl(inputEl);
  el.innerText = "";
  inputEl.classList.remove("has-error");
}

function isEmpty(value) {
  return value.replace(/^\s+|\s+$/g, "") === "";
}

// -----------------------------
// Login page logic (file.html)
// -----------------------------
var loginEmail = document.getElementById("input");
var loginPassword = document.getElementById("password");
var loginButton = document.getElementById("button");

if (loginEmail && loginPassword && loginButton) {
  // Prefill email after registration
  try {
    var lastEmail = localStorage.getItem("clase01_last_email");
    if (lastEmail) loginEmail.value = lastEmail;
  } catch (e) {}

  loginButton.addEventListener("click", function () {
    var okEmail = !isEmpty(loginEmail.value);
    var okPass = !isEmpty(loginPassword.value);

    if (!okEmail) setError(loginEmail, "Por favor llena tu email.");
    else clearError(loginEmail);

    if (!okPass) setError(loginPassword, "Por favor llena tu contraseña.");
    else clearError(loginPassword);

    if (!(okEmail && okPass)) return;

    var users = loadUsers();
    var user = findUserByEmail(users, loginEmail.value);
    var passOk = user && user.password === loginPassword.value;

    if (!passOk) {
      setError(loginPassword, "Credenciales incorrectas.");
      return;
    }

    try {
      localStorage.setItem(SESSION_KEY, normalizeEmail(loginEmail.value));
    } catch (e) {}

    window.location.href = "galeria.html";
  });

  loginEmail.addEventListener("input", function () {
    clearError(loginEmail);
  });

  loginPassword.addEventListener("input", function () {
    clearError(loginPassword);
  });
}

// -----------------------------
// Gallery header logic (galeria.html)
// -----------------------------
var logoutButton = document.getElementById("logoutButton");
if (logoutButton) {
  // Basic protection: if no session, go back to login
  try {
    var sessionEmail = localStorage.getItem(SESSION_KEY);
    if (!sessionEmail) window.location.href = "file.html";
  } catch (e) {
    window.location.href = "file.html";
  }

  logoutButton.addEventListener("click", function () {
    var ok = window.confirm("¿Seguro que quieres cerrar sesión?");
    if (!ok) return;
    try {
      localStorage.removeItem(SESSION_KEY);
    } catch (e) {}
    window.location.href = "file.html";
  });
}

// -----------------------------
// Register page logic (index.html)
// -----------------------------
var firstName = document.getElementById("firstName");
var lastName = document.getElementById("lastName");
var dob = document.getElementById("dob");
var regEmail = document.getElementById("regEmail");
var regPassword = document.getElementById("regPassword");
var regPassword2 = document.getElementById("regPassword2");
var registerButton = document.getElementById("registerButton");

function isValidEmailSimple(value) {
  var v = normalizeEmail(value);
  return v.indexOf("@") !== -1 && v.indexOf(".") !== -1;
}

if (
  firstName &&
  lastName &&
  dob &&
  regEmail &&
  regPassword &&
  regPassword2 &&
  registerButton
) {
  registerButton.addEventListener("click", function () {
    var okFirst = !isEmpty(firstName.value);
    var okLast = !isEmpty(lastName.value);
    var okDob = !isEmpty(dob.value);
    var okEmail = !isEmpty(regEmail.value) && isValidEmailSimple(regEmail.value);
    var okPass = !isEmpty(regPassword.value);
    var okPass2 = !isEmpty(regPassword2.value) && regPassword2.value === regPassword.value;

    if (!okFirst) setError(firstName, "Escribe tu nombre.");
    else clearError(firstName);

    if (!okLast) setError(lastName, "Escribe tu apellido.");
    else clearError(lastName);

    if (!okDob) setError(dob, "Selecciona tu fecha de nacimiento.");
    else clearError(dob);

    if (!okEmail) setError(regEmail, "Escribe un email válido.");
    else clearError(regEmail);

    if (!okPass) setError(regPassword, "Escribe una contraseña.");
    else clearError(regPassword);

    if (!okPass2) setError(regPassword2, "Las contraseñas no coinciden.");
    else clearError(regPassword2);

    if (!(okFirst && okLast && okDob && okEmail && okPass && okPass2)) return;

    var users = loadUsers();
    var exists = findUserByEmail(users, regEmail.value);
    if (exists) {
      setError(regEmail, "Este email ya está registrado.");
      return;
    }

    users.push({
      firstName: firstName.value.replace(/^\s+|\s+$/g, ""),
      lastName: lastName.value.replace(/^\s+|\s+$/g, ""),
      dob: dob.value,
      email: normalizeEmail(regEmail.value),
      password: regPassword.value
    });

    saveUsers(users);

    try {
      localStorage.setItem("clase01_last_email", normalizeEmail(regEmail.value));
    } catch (e) {}

    window.location.href = "file.html";
  });

  firstName.addEventListener("input", function () {
    clearError(firstName);
  });
  lastName.addEventListener("input", function () {
    clearError(lastName);
  });
  dob.addEventListener("input", function () {
    clearError(dob);
  });
  regEmail.addEventListener("input", function () {
    clearError(regEmail);
  });
  regPassword.addEventListener("input", function () {
    clearError(regPassword);
  });
  regPassword2.addEventListener("input", function () {
    clearError(regPassword2);
  });
}