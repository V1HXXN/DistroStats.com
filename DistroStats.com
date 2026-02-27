<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>DistroStats</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
:root{
 --bg:#0e0e0e; --card:#161616; --text:white; --accent:#1db954;
}
.light{ --bg:#f4f4f4; --card:white; --text:#111; --accent:#1db954; }

body{
 margin:0; font-family:Arial, sans-serif; background:var(--bg); color:var(--text);
 transition:.3s;
}
.sidebar{
 width:220px; background:var(--card); height:100vh; position:fixed;
 padding-top:20px;
}
.sidebar h2{ text-align:center; margin-bottom:20px; }
.sidebar a{
 display:block; padding:15px; cursor:pointer; text-decoration:none; color:var(--text);
 font-weight:600;
}
.sidebar a:hover{ background:#222; }

.main{ margin-left:220px; padding:20px; }
.topbar{
 display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;
}
.counter{
 font-size:42px; color:var(--accent); margin-bottom:20px;
}
.section{ display:none; }
.active{ display:block; }
button{
 padding:8px 15px; cursor:pointer; margin:5px 0;
 background:var(--accent);
 border:none;
 color:#fff;
 border-radius:4px;
 transition:background 0.3s ease;
}
button:hover{
 background:#17a54d;
}

.card{
 background:var(--card); padding:20px; border-radius:8px; margin-bottom:20px;
}
input{
 padding:6px; width:80px; border-radius:4px; border:none; outline:none;
}

/* Artist Stats */
.artist-stats{
 display:flex;
 justify-content:space-between;
 flex-wrap:wrap;
 margin-bottom:30px;
}
.artist-box{
 flex:1 1 30%;
 background:var(--card);
 margin:10px;
 padding:20px;
 border-radius:10px;
 text-align:center;
 box-shadow: 0 0 5px rgba(29, 185, 84, 0.7);
}
.artist-box h3{
 margin-bottom:10px;
 color:var(--accent);
 font-weight:700;
}
.artist-box p{
 font-size:24px;
 margin:0;
 font-weight:600;
}

/* Popular songs list */
.popular-songs{
 max-width:700px;
 margin:0 auto;
}
.popular-songs h2{
 margin-bottom:15px;
 font-weight:700;
 color: var(--accent);
}
.song-item{
 display:flex;
 align-items:center;
 justify-content:space-between;
 background:var(--card);
 padding:12px 15px;
 margin-bottom:8px;
 border-radius:8px;
 cursor:pointer;
 transition: background 0.2s ease;
}
.song-item:hover{
 background:#222;
}
.song-info{
 display:flex;
 align-items:center;
 gap:15px;
 flex-grow:1;
}
.play-btn{
 width:36px; height:36px;
 background:var(--accent);
 border-radius:50%;
 display:flex;
 align-items:center;
 justify-content:center;
 cursor:pointer;
 flex-shrink:0;
 transition:background 0.3s ease;
}
.play-btn:hover{
 background:#17a54d;
}
.play-btn svg{
 fill:#fff;
 width:16px;
 height:16px;
 pointer-events:none;
}
.song-text{
 display:flex;
 flex-direction: column;
}
.song-title{
 font-weight:600;
 font-size:16px;
 color:var(--text);
}
.song-artist{
 font-size:12px;
 color:#888;
 margin-top:2px;
}
.stream-count{
 font-weight:700;
 font-size:14px;
 color:#999;
 min-width:110px;
 text-align:right;
 user-select:none;
}

/* Responsive */
@media (max-width:768px){
 .sidebar{
  position:relative;
  width:100%;
  height:auto;
  display:flex;
  justify-content:space-around;
 }
 .main{ margin-left:0; }
 .artist-box{ flex:1 1 100%; margin:10px 0; }
 .popular-songs{ max-width:100%; padding:0 10px; }
}
</style>
</head>
<body>

<!-- Loading Screen -->
<div id="loadingScreen" style="position:fixed;width:100%;height:100%;background:black;display:flex;justify-content:center;align-items:center;font-size:28px;z-index:9999;">
 Loading DistroStats...
</div>

<!-- Login -->
<div id="loginPage" style="display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;">
 <h1>DistroStats</h1>
 <input type="text" placeholder="Username" />
 <input type="password" placeholder="Password" />
 <button onclick="login()">Login</button>
</div>

<!-- Dashboard -->
<div class="dashboard" id="dashboard" style="display:none;">

<div class="sidebar">
 <h2>DistroStats</h2>
 <a onclick="route('dashboardSection')">Dashboard</a>
 <a onclick="route('analyticsSection')">Analytics</a>
 <a onclick="route('earningsSection')">Earnings</a>
 <a onclick="route('artistSection')">Artist</a>
 <a onclick="route('adminSection')">Admin</a>
 <a onclick="toggleTheme()">Toggle Theme</a>
</div>

<div class="main">

<div class="topbar">
 <div class="card">
  🔔 New milestone reached!<br>📈 Streams trending!<br>💰 Revenue spike detected
 </div>
 <div>
  <img src="https://via.placeholder.com/40" style="border-radius:50%" alt="Profile"/>
  <div>V1HXXN</div>
 </div>
</div>

<!-- Dashboard Section -->
<div id="dashboardSection" class="section active">
 <div class="card">
  <h2>Live Visitors Online</h2>
  <div class="counter" id="liveVisitors">1,284</div>
 </div>
 <div class="card">
  <h2>Total Views</h2>
  <div class="counter" id="viewsCounter">347,898,009</div>
 </div>
</div>

<!-- Analytics Section -->
<div id="analyticsSection" class="section">
 <div class="card">
  <h2>Growth Overview</h2>
  <canvas id="growthChart"></canvas>
 </div>
 <div class="card">
  <h2>Country Breakdown</h2>
  <canvas id="countryChart"></canvas>
 </div>
</div>

<!-- Earnings Section -->
<div id="earningsSection" class="section">
 <div class="card">
  <h2>Earnings</h2>
  <div class="counter" id="earningsCounter">$115,343.90</div>
 </div>
 <button onclick="downloadReport()">Download Report</button>
</div>

<!-- Artist Section -->
<div id="artistSection" class="section">
 <div class="artist-stats">
  <div class="artist-box">
   <h3>Monthly Listeners</h3>
   <p id="monthlyListeners">579,000</p>
  </div>
  <div class="artist-box">
   <h3>Total Streams</h3>
   <p id="totalStreams">567,000,000</p>
  </div>
  <div class="artist-box">
   <h3>Followers</h3>
   <p id="followers">26,707</p>
  </div>
 </div>

 <div class="popular-songs">
  <h2>Some of ur most popular songs</h2>
  
  <!-- Song items will be inserted by JS -->
  <div id="songList"></div>
 </div>
</div>

<!-- Admin Section -->
<div id="adminSection" class="section">
 <div class="card">
  <h2>Admin Panel</h2>
  <p>Views increase per cycle:</p>
  <input id="viewsInc" value="143" />
  <p>Earnings increase per cycle:</p>
  <input id="earningsInc" value="36" />
  <p>Followers increment:</p>
  <input id="followersInc" value="58" />
  <button onclick="applyChanges()">Apply Changes</button>
 </div>
</div>

</div>
</div>

<script>
// Loading & Login
setTimeout(() => document.getElementById("loadingScreen").style.display = "none", 2000);
function login() {
 document.getElementById("loginPage").style.display = "none";
 document.getElementById("dashboard").style.display = "block";
}

// Routing
function route(id) {
 document.querySelectorAll(".section").forEach(s => s.classList.remove("active"));
 document.getElementById(id).classList.add("active");
}

// Theme
function toggleTheme() {
 document.body.classList.toggle("light");
}

// Smooth rolling animation
function animateValue(obj, start, end, duration, prefix = "") {
 let startTime = null;
 function animation(currentTime) {
  if (!startTime) startTime = currentTime;
  let progress = Math.min((currentTime - startTime) / duration, 1);
  let value = Math.floor(progress * (end - start) + start);
  obj.innerText = prefix + value.toLocaleString();
  if (progress < 1) {
   requestAnimationFrame(animation);
  }
 }
 requestAnimationFrame(animation);
}

// Values
let views = 347898009,
 earnings = 115343.90,
 liveVisitors = 1284;
let monthlyListeners = 579000,
 totalStreams = 567000000,
 followers = 26707;

let viewsIncrement = 143,
 earningsIncrement = 36,
 followersIncrement = 58;

// Views update
setInterval(() => {
 let newVal = views + viewsIncrement;
 animateValue(document.getElementById("viewsCounter"), views, newVal, 800);
 views = newVal;
 updateCharts();
}, 5000);

// Earnings update every 7 seconds
setInterval(() => {
 let newVal = earnings + earningsIncrement;
 animateValue(
  document.getElementById("earningsCounter"),
  earnings,
  newVal,
  800,
  "$"
 );
 earnings = newVal;
}, 7000);

// Followers increment every 6.7 seconds
setInterval(() => {
 let newVal = followers + followersIncrement;
 animateValue(document.getElementById("followers"), followers, newVal, 800);
 followers = newVal;
}, 6700);

// Live visitors realistic fluctuation
function updateLiveVisitors() {
 let change = Math.floor(Math.random() * 15);
 if (Math.random() > 0.5) liveVisitors += change;
 else liveVisitors -= change;

 if (liveVisitors < 950) liveVisitors = 950;
 if (liveVisitors > 2400) liveVisitors = 2400;

 animateValue(
  document.getElementById("liveVisitors"),
  parseInt(document.getElementById("liveVisitors").innerText.replace(/,/g, "")),
  liveVisitors,
  600
 );
}
setInterval(updateLiveVisitors, 3000);

// Charts
let growthChart = new Chart(document.getElementById("growthChart"), {
 type: "line",
 data: {
  labels: ["Start"],
  datasets: [
   {
    label: "Views",
    data: [views],
    borderColor: "#1db954",
    tension: 0.4,
   },
  ],
 },
});

let countryChart = new Chart(document.getElementById("countryChart"), {
 type: "doughnut",
 data: {
  labels: ["UK", "India", "USA", "Germany", "Canada"],
  datasets: [
   {
    data: [35, 30, 15, 10, 10],
    backgroundColor: [
     "#1db954",
     "#ff6384",
     "#36a2eb",
     "#ffcd56",
     "#9966ff",
    ],
   },
  ],
 },
});

// REALISTIC fluctuating graph matching your sample shape
let graphPhases = [
 { duration: 4, changePerTick: 8000 }, // steady up
 { duration: 2, changePerTick: -6000 }, // dip
 { duration: 3, changePerTick: 10000 }, // spike
 { duration: 3, changePerTick: -4000 }, // small dip
 { duration: 4, changePerTick: 8000 }, // steady up
];

let currentPhase = 0;
let phaseTick = 0;
function updateCharts() {
 const lastValue =
  growthChart.data.datasets[0].data[
   growthChart.data.datasets[0].data.length - 1
  ];

 let phase = graphPhases[currentPhase];
 let realisticValue = lastValue + phase.changePerTick;

 if (phaseTick >= phase.duration) {
  currentPhase = (currentPhase + 1) % graphPhases.length;
  phaseTick = 0;
 } else {
  phaseTick++;
 }

 growthChart.data.labels.push("");
 growthChart.data.datasets[0].data.push(realisticValue);
 growthChart.update();
}

// Admin
function applyChanges() {
 viewsIncrement = parseInt(document.getElementById("viewsInc").value);
 earningsIncrement = parseInt(document.getElementById("earningsInc").value);
 followersIncrement = parseInt(document.getElementById("followersInc").value);
 alert("Growth rates updated.");
}

// Fake report download
function downloadReport() {
 let csv =
  "Metric,Value\nViews," +
  views +
  "\nEarnings," +
  earnings.toFixed(2);
 let blob = new Blob([csv], { type: "text/csv" });
 let link = document.createElement("a");
 link.href = URL.createObjectURL(blob);
 link.download = "DistroStats_Report.csv";
 link.click();
}

/* ------------ POPULAR SONGS PLAYER ------------ */

const songs = [
 {
  title: "LOUCARA LETAL",
  streams: 276909788,
  audioSrc: "LOUCARA LETAL.mp3",
 },
 {
  title: "LUA NA PRAÇA",
  streams: 200899256,
  audioSrc: "LUA NA PRAÇA.mp3",
 },
 {
  title: "NOCHE ETERNA",
  streams: 180778994,
  audioSrc: "NOCHE ETERNA.mp3",
 },
 {
  title: "MUNCHAUSEN FUNK",
  streams: 132990367,
  audioSrc: "MUNCHAUSEN FUNK.mp3",
 },
 {
  title: "MONTAGEM VOZES TALENTINHO",
  streams: 117230499,
  audioSrc: "MONTAGEM VOZES TALENTINHO.mp3",
 },
 {
  title: "MONTAGEM BATIDA",
  streams: 100546899,
  audioSrc: "MONTAGEM BATIDA.mp3",
 },
 {
  title: "VAI CONEXÃO",
  streams: 57680921,
  audioSrc: "VAI CONEXÃO.mp3",
 },
];

const artistName = "V1HXXN";

const songListContainer = document.getElementById("songList");
let currentAudio = null;
let currentPlayingIndex = -1;

function formatNumber(num) {
 return num.toLocaleString();
}

function createPlayIcon() {
 return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" 
 stroke-linecap="round" stroke-linejoin="round" class="feather feather-play"><polygon points="5 3 19 12 5 21 5 3"/></svg>`;
}

function createPauseIcon() {
 return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" 
 stroke-linecap="round" stroke-linejoin="round" class="feather feather-pause"><rect x="6" y="4" width="4" height="16"/>
 <rect x="14" y="4" width="4" height="16"/></svg>`;
}

function createSongItem(song, index) {
 // Create container
 const div = document.createElement("div");
 div.className = "song-item";

 // Play button
 const playBtn = document.createElement("div");
 playBtn.className = "play-btn";
 playBtn.innerHTML = createPlayIcon();

 // Audio element
 const audio = document.createElement("audio");
 audio.src = song.audioSrc;

 // Song info
 const info = document.createElement("div");
 info.className = "song-info";

 const title = document.createElement("div");
 title.className = "song-title";
 title.textContent = song.title;

 const artist = document.createElement("div");
 artist.className = "song-artist";
 artist.textContent = artistName;

 info.appendChild(title);
 info.appendChild(artist);

 // Stream count
 const streams = document.createElement("div");
 streams.className = "stream-count";
 streams.textContent = formatNumber(song.streams);

 // Play/pause logic
 playBtn.onclick = () => {
  if (currentPlayingIndex === index) {
   // Toggle pause/play on current audio
   if (audio.paused) {
    audio.play();
    playBtn.innerHTML = createPauseIcon();
   } else {
    audio.pause();
    playBtn.innerHTML = createPlayIcon();
   }
  } else {
   // Pause old audio if playing
   if (currentAudio) {
    currentAudio.pause();
    // Reset previous play button icon
    const oldBtn = songListContainer.children[currentPlayingIndex].querySelector(
     ".play-btn"
    );
    if (oldBtn) oldBtn.innerHTML = createPlayIcon();
   }
   // Play new audio
   audio.play();
   playBtn.innerHTML = createPauseIcon();
   currentAudio = audio;
   currentPlayingIndex = index;
  }
 };

 // Pause audio when ended
 audio.onended = () => {
  playBtn.innerHTML = createPlayIcon();
  currentPlayingIndex = -1;
  currentAudio = null;
 };

 // Assemble
 div.appendChild(playBtn);
 div.appendChild(info);
 div.appendChild(streams);
 div.appendChild(audio);

 return div;
}

// Add songs to DOM
songs.forEach((song, i) => {
 songListContainer.appendChild(createSongItem(song, i));
});
</script>

</body>
</html>
