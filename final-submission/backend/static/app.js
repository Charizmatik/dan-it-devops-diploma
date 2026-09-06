const fields = ["service", "environment", "runtime", "release", "delivery"];
document.getElementById("publicHostname").textContent = window.location.hostname || "app.mikoladolia.pp.ua";

function formatUptime(totalSeconds) {
  const seconds = Math.max(0, Number(totalSeconds) || 0);
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  if (days) return `${days}d ${hours}h`;
  if (hours) return `${hours}h ${minutes}m`;
  return `${minutes}m ${seconds % 60}s`;
}

function setText(id, value) {
  const element = document.getElementById(id);
  if (element) element.textContent = value ?? "—";
}

async function refreshStatus() {
  try {
    const response = await fetch("/api/status", { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();

    document.body.classList.remove("offline");
    setText("connectionText", "LIVE CONNECTION");
    setText("status", data.status === "ok" ? "ALL SYSTEMS OPERATIONAL" : String(data.status).toUpperCase());
    setText("podIp", data.ip);
    setText("uptime", formatUptime(data.uptime_seconds));
    setText("serverTime", new Date(data.server_time).toLocaleTimeString([], { hour12: false, timeZone: "UTC" }) + " UTC");
    fields.forEach((field) => setText(field, data[field]));
  } catch (error) {
    document.body.classList.add("offline");
    setText("connectionText", "CONNECTION LOST");
    setText("status", "TELEMETRY UNAVAILABLE");
  }
}

refreshStatus();
setInterval(refreshStatus, 5000);
