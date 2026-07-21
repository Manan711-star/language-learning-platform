const API_BASE = '/api';

const API = {
  async request(endpoint, options = {}) {
    const token = localStorage.getItem('token');
    const headers = { 'Content-Type': 'application/json', ...options.headers };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const response = await fetch(`${API_BASE}${endpoint}`, { ...options, headers });
    const data = await response.json();

    if (!response.ok) {
      if (response.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        if (!window.location.pathname.includes('login') && !window.location.pathname.includes('register') && window.location.pathname !== '/') {
          window.location.href = 'login.html';
        }
      }
      throw new Error(data.error || 'Something went wrong');
    }
    return data;
  },

  get(endpoint) { return this.request(endpoint); },
  post(endpoint, body) { return this.request(endpoint, { method: 'POST', body: JSON.stringify(body) }); },
  put(endpoint, body) { return this.request(endpoint, { method: 'PUT', body: JSON.stringify(body) }); },

  async upload(endpoint, formData) {
    const token = localStorage.getItem('token');
    const headers = {};
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const response = await fetch(`${API_BASE}${endpoint}`, {
      method: 'POST',
      body: formData,
      headers,
    });
    const data = await response.json();

    if (!response.ok) {
      if (response.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        if (!window.location.pathname.includes('login') && !window.location.pathname.includes('register') && window.location.pathname !== '/') {
          window.location.href = 'login.html';
        }
      }
      throw new Error(data.error || 'Something went wrong');
    }
    return data;
  },
};

function isLoggedIn() {
  return !!localStorage.getItem('token');
}

function getUser() {
  const user = localStorage.getItem('user');
  return user ? JSON.parse(user) : null;
}

function setAuth(token, user) {
  localStorage.setItem('token', token);
  localStorage.setItem('user', JSON.stringify(user));
}

function logout() {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  window.location.href = 'index.html';
}

function showToast(message, type = 'success') {
  const container = document.getElementById('toast-container') || createToastContainer();
  const toast = document.createElement('div');
  toast.className = `alert alert-${type} alert-dismissible fade show`;
  toast.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 4000);
}

function createToastContainer() {
  const container = document.createElement('div');
  container.id = 'toast-container';
  container.className = 'toast-container';
  document.body.appendChild(container);
  return container;
}

function updateNavbar() {
  const authLinks = document.getElementById('auth-links');
  const userMenu = document.getElementById('user-menu');
  if (!authLinks) return;

  if (isLoggedIn()) {
    const user = getUser();
    authLinks.classList.add('d-none');
    if (userMenu) {
      userMenu.classList.remove('d-none');
      const nameEl = userMenu.querySelector('.user-name');
      if (nameEl) nameEl.textContent = user?.full_name || user?.username || 'User';
      
      const avatarEl = userMenu.querySelector('.user-avatar');
      if (avatarEl && user?.avatar_url) {
        avatarEl.src = user.avatar_url.startsWith('uploads/')
          ? `${user.avatar_url}?t=${Date.now()}`
          : user.avatar_url;
        avatarEl.onerror = function() {
          this.src = 'assets/images/avatar-default.svg';
        };
      }
    }
  } else {
    authLinks.classList.remove('d-none');
    if (userMenu) userMenu.classList.add('d-none');
  }
}

function requireAuth() {
  if (!isLoggedIn()) {
    window.location.href = 'login.html';
    return false;
  }
  return true;
}

function formatMarkdown(text) {
  if (!text) return '';
  return text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/^- (.+)$/gm, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/s, '<ul class="list-unstyled ms-3">$1</ul>')
    .replace(/\n\n/g, '</p><p>')
    .replace(/\n/g, '<br>');
}

document.addEventListener('DOMContentLoaded', updateNavbar);
