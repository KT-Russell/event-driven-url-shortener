const form = document.getElementById("shorten-form");
const longUrlInput = document.getElementById("long-url");

const resultPanel = document.getElementById("result-panel");
const shortUrlElement = document.getElementById("short-url");
const copyButton = document.getElementById("copy-button");

const messageElement = document.getElementById("message");

const totalUrlsElement = document.getElementById("total-urls");
const totalClicksElement = document.getElementById("total-clicks");
const clicksTodayElement = document.getElementById("clicks-today");

const analyticsStatus = document.getElementById("analytics-status");
const systemLog = document.getElementById("system-log-content");

function showMessage(message, isError = false) {
    messageElement.textContent = message;
    messageElement.hidden = false;
    messageElement.classList.toggle("error", isError);
}

function clearMessage() {
    messageElement.hidden = true;
    messageElement.textContent = "";
    messageElement.classList.remove("error");
}

function addLog(message) {
    const line = document.createElement("p");

    line.textContent = `> ${message}`;

    systemLog.appendChild(line);
    systemLog.scrollTop = systemLog.scrollHeight;
}

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    clearMessage();
    resultPanel.hidden = true;

    const longUrl = longUrlInput.value.trim();

    if (!longUrl) {
        showMessage("PLEASE ENTER A URL.", true);
        addLog("INVALID INPUT RECEIVED");
        return;
    }

    addLog("SHORTEN REQUEST SENT");

    try {
        const response = await fetch("/shorten", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                url: longUrl
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();

        const shortUrl = data.short_url.startsWith("http")
            ? data.short_url
            : `${window.location.origin}/${data.short}`;

        shortUrlElement.href = shortUrl;
        shortUrlElement.textContent = shortUrl;

        resultPanel.hidden = false;

        addLog(`SHORT LINK GENERATED: ${data.short}`);

        await loadAnalytics();

    } catch (error) {
        console.error(error);

        showMessage(
            "ERROR: URL COULD NOT BE SHORTENED.",
            true
        );

        addLog("SHORTEN REQUEST FAILED");
    }
});

copyButton.addEventListener("click", async () => {
    const value = shortUrlElement.textContent;

    if (!value) {
        return;
    }

    try {
        await navigator.clipboard.writeText(value);

        copyButton.textContent = "COPIED";

        addLog("SHORT LINK COPIED TO CLIPBOARD");

        setTimeout(() => {
            copyButton.textContent = "COPY";
        }, 1200);

    } catch {
        showMessage(
            "COPY FAILED. SELECT THE LINK MANUALLY.",
            true
        );

        addLog("CLIPBOARD OPERATION FAILED");
    }
});

async function loadAnalytics() {
    analyticsStatus.textContent = "CONNECTING...";

    try {
        const dashboardBase =
            window.location.hostname === "localhost"
                ? "http://localhost:8081"
                : "";

        const response = await fetch(
            `${dashboardBase}/summary`
        );

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();

        totalUrlsElement.textContent =
            data.total_urls ?? 0;

        totalClicksElement.textContent =
            data.total_clicks ?? 0;

        clicksTodayElement.textContent =
            data.clicks_today ?? 0;

        analyticsStatus.textContent = "ONLINE";

        addLog("ANALYTICS SERVICE ONLINE");

    } catch (error) {
        console.error(error);

        totalUrlsElement.textContent = "--";
        totalClicksElement.textContent = "--";
        clicksTodayElement.textContent = "--";

        analyticsStatus.textContent =
            "UNAVAILABLE";

        addLog("ANALYTICS SERVICE UNAVAILABLE");
    }
}

loadAnalytics();