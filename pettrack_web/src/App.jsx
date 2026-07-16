import { useState, useEffect, useRef } from 'react';
import {
  Shield, Settings, Wifi, WifiOff,
  LayoutDashboard, HelpCircle, LogOut,
  User, Clock, Zap, Moon, Sun, Globe, Menu, X, Battery, BatteryCharging, Map, Trash2, Plus, Save, Heart
} from 'lucide-react';

const locales = {
  hu: {
    welcome: "Üdvözöl a PetTrack",
    enterUrl: "Add meg a server URL-t és a portot",
    enterToken: "Add meg a titkos tokent a csatlakozáshoz.",
    placeholderUrl: "http://192.168.1.x:8000",
    placeholderToken: "Ide másold a tokent...",
    connect: "Csatlakozás",
    appTitle: "PetTrack",
    appSubtitle: "Kamera Monitor",
    dashboard: "Irányítópult",
    settings: "Beállítások",
    help: "Támogatás",
    logout: "Kijelentkezés",
    lastUpdate: "Utolsó frissítés",
    now: "Most",
    account: "Fiók",
    live: "ÉLŐ ADÁS",
    offline: "OFFLINE",
    camConnecting: "Kamera csatlakozása...",
    camView: "Kamera nézet",
    camWaiting: "Készenlétben...",
    activeTime: "Aktív idő",
    mins: "perc",
    restTime: "Pihenőidő",
    hours: "óra",
    lastSeen: "Utoljára látva",
    mostSeen: "Legtöbbször itt",
    noData: "Nincs adat",
    profile: "Profil",
    loadingData: "Adatok betöltése...",
    eventLog: "Eseménynapló",
    noEvents: "Jelenleg nincsenek események.",
    petName: "Kedvenc neve",
    petType: "Fajta / Típus",
    uploadPicture: "Profilkép feltöltése",
    save: "Mentés",
    saveSuccess: "Sikeresen mentve!",
    chooseRole: "Válaszd ki az ezköz szerepét",
    roleMonitor: "Beállítás mint Kamera (Monitor)",
    roleMonitorDesc: "Ez a telefon fofgja venni és közvetíteni a videót.",
    roleClient: "Beállítás mint Kliens (Felügyelő)",
    roleClientDesc: "Ezen a telefonon csak nézni és kezelni akarom a kamerát.",
    resetRole: "Ezköz szepkörének törlése",
    monitorActive: "A kamera aktív",
    monitorStreaming: "Folyamatos közvetítés a szerver felé...",
    errorMedia: "Nem sikerült hozzáférni a kamerához!",
    petTypes: {
      dog: "Kutya",
      cat: "Macska",
      rabbit: "Nyúl",
      guineapig: "Tengerimalac",
      bird: "Madár",
      other: "Egyéb"
    },
    zonesSaved: "Zónák sikeresen elmentve!",
    setupZones: "Kamera képe & rajzolás",
    draw: "Kattints a képre, hogy pontokat rajzolj a területre",
    noImage: "Nincs élő kamera kép",
    manageZones: "Zónák Kezelése",
    newZone: "Új zóna rajzolása",
    zoneNamePlaceholder: "Zóna neve (pl. Ajtó, Kanapé)",
    cancel: "Mégse",
    addZone: "Hozzáadás",
    zoneError: "Adj meg egy nevet és legalább 3 pontot egy érvényes zónához!",
    noZones: "Nincsenek felvett zónák",
    saveFinal: "Végleges Mentés",
    safeZone: "Biztonságos (Safe)",
    dangerZone: "Veszélyes (Danger)",
    manageMedical: "Egészségügy",
    medications: "Gyógyszerek",
    vaccines: "Oltások",
    dose: "Dózis",
    interval: "Gyakoriság",
    alertEnabled: "Értesítés bekapcsolva",
    dateGiven: "Beadva",
    nextDue: "Következő",
    noData: "Nincs megjeleníthető adat.",
    loading: "Betöltés",
    addMedication: "Új gyógyszer",
    addVaccine: "Új oltás",
    name: "Név",
    cancel: "Mégse",
    save: "Mentés",
    eventMovement: "Mozgás érzékelve",
    eventZoneEnter: "Belépés zónába",
    eventZoneExit: "Kilépés zónából",
    deviceSettings: "Eszköz beállítások",
    deviceSettingsDesc: "Ha ezen a gépen akarod futtatni a kamerát vagy rosszul választottál korábban, itt visszaállíthatod az eszköz szerepkörét."
  },
  en: {
    welcome: "Welcome to PetTrack",
    enterUrl: "Enter the server URL and port",
    enterToken: "Enter the secret token to connect.",
    placeholderUrl: "http://192.168.1.x:8000",
    placeholderToken: "Paste your token here...",
    connect: "Connect",
    appTitle: "PetTrack",
    appSubtitle: "Camera system",
    dashboard: "Dashboard",
    settings: "Settings",
    help: "Support",
    logout: "Log Out",
    lastUpdate: "Last updated",
    now: "Just now",
    account: "Account",
    live: "LIVE FEED",
    offline: "OFFLINE",
    camConnecting: "Connecting to camera...",
    camView: "Camera view",
    camWaiting: "Standing by...",
    activeTime: "Active time",
    mins: "mins",
    restTime: "Rest Time",
    hours: "hours",
    lastSeen: "Last seen",
    mostSeen: "Most seen",
    noData: "No data",
    profile: "Profile",
    loadingData: "Loading data...",
    eventLog: "Event Log",
    noEvents: "No events recorded yet.",
    petName: "Pet's Name",
    petType: "Breed / Type",
    uploadPicture: "Upload profile picture",
    save: "Save",
    saveSuccess: "Saved successfully!",
    chooseRole: "Choose device role",
    roleMonitor: "Set up as Camera (Monitor)",
    roleMonitorDesc: "This phone will capture and stream video.",
    roleCleint: "Set up as Viewer (Client)",
    roleClientDesc: "I want to watch and manage the camera on this device,",
    resetRole: "Reset Device Role",
    monitorActive: "Camera Active",
    monitorStreaming: "Streaming continously to the server...",
    errorMedia: "Failed to access camera!",
    petTypes: {
      dog: "Dog",
      cat: "Cat",
      rabbit: "Rabbit",
      guineapig: "Guinea Pig",
      bird: "Bird",
      other: "Other"
    },
    zonesSaved: "Zones saved successfully!",
    setupZones: "Camera image & drawing",
    draw: "Click on the picture to put dots on the image.",
    noImage: "No live view available.",
    manageZones: "Manage Zones",
    newZone: "Draw new zone",
    zoneNamePlaceholder: "Zone name (e.g. Door, Couch)",
    cancel: "Cancel",
    addZone: "Add Zone",
    zoneError: "Provide a name and at least 3 points for a valid zone!",
    noZones: "No zones defined yet",
    saveFinal: "Final Save",
    safeZone: "Safe",
    dangerZone: "Danger",
    manageMedical: "Medical Data",
    medications: "Medications",
    vaccines: "Vaccines",
    dose: "Dosage",
    interval: "Frequency",
    alertEnabled: "Alert Enabled",
    dateGiven: "Date Given",
    nextDue: "Next Due",
    noData: "No data availabe.",
    loading: "Loading",
    addMedication: "Add Medication",
    addVaccine: "Add Vaccine",
    name: "Name",
    cancel: "Cancel",
    save: "Save",
    eventMovement: "Movement detected",
    eventZoneEnter: "Entered zone",
    eventZoneExit: "Left zone",
    deviceSettings: "Device Settings",
    deviceSettingsDesc: "If you want to run the camera on this device or made a wrong choice earlier, you can reset the device role here."
  }
};

const browserLang = navigator.language.startsWith('hu') ? 'hu' : 'en';

function ZoneEditor({ serverUrl, token, frameUrl, t }) {
  const [zones, setZones] = useState([]);
  const [currentZone, setCurrentZone] = useState(null);
  const [zoneName, setZoneName] = useState("");
  const [zoneType, setZoneType] = useState("safe");
  const svgRef = useRef(null);
  const [size, setSize] = useState({ w: 800, h: 450 });

  useEffect(() => {
    if (!serverUrl) return;
    fetch(`${serverUrl}/api/zones?token=${token}`)
      .then(r => r.json())
      .then(d => { if (d.zones) setZones(d.zones); })
      .catch(console.error);
  }, [serverUrl]);

  useEffect(() => {
    const updateSize = () => {
      if (svgRef.current) {
        const rect = svgRef.current.getBoundingClientRect();
        if (rect.width > 0) setSize({ w: rect.width, h: rect.height });
      }
    };
    updateSize();
    // Kis késleltetéssel is frissítünk, ha az elrendezés ugrana
    const timeoutId = setTimeout(updateSize, 100);
    window.addEventListener('resize', updateSize);
    return () => {
      clearTimeout(timeoutId);
      window.removeEventListener('resize', updateSize);
    };
  }, [frameUrl]);

  const handleSvgClick = (e) => {
    if (!currentZone) return;
    const rect = svgRef.current.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;
    setCurrentZone([...currentZone, { x, y }]);
  };

  const saveZones = async () => {
    await fetch(`${serverUrl}/api/zones`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(zones)
    });
    alert(t.zonesSaved);
  };

  return (
    <div className="app-card overflow-hidden flex flex-col lg:flex-row p-0">
      <div className="flex-1 p-6 flex flex-col lg:border-r border-border bg-slate-900/20">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-xl font-bold text-slate-800">{t.setupZones}</h3>
          <span className="text-xs font-bold text-slate-500 bg-slate-200 px-3 py-1 rounded-full">{t.draw}</span>
        </div>
        <div className="relative w-full aspect-video bg-slate-900 rounded-xl overflow-hidden cursor-crosshair border border-slate-800 shadow-inner">
          {frameUrl ? <img src={frameUrl} alt="Camera" className="w-full h-full object-cover" /> : <div className="w-full h-full flex items-center justify-center text-slate-500">{t.noImage}</div>}
          <svg ref={svgRef} onClick={handleSvgClick} className="absolute inset-0 w-full h-full">
            {zones.map((z, i) => {
              const color = z.type === 'danger' ? '#EF4444' : '#4DB6AC';
              const fillColor = z.type === 'danger' ? 'rgba(239, 68, 68, 0.3)' : 'rgba(77, 182, 172, 0.3)';

              const isAbsolute = z.polygon && z.polygon.some(p => p.x > 1.5 || p.y > 1.5);
              const scaleX = isAbsolute ? (size.w / 358) : size.w;
              const scaleY = isAbsolute ? (size.h / 300) : size.h;

              let cx = 0, cy = 0;
              if (z.polygon && z.polygon.length > 0) {
                z.polygon.forEach(p => { cx += p.x; cy += p.y; });
                cx /= z.polygon.length;
                cy /= z.polygon.length;
              }

              return (
                <g key={i}>
                  <polygon
                    points={(z.polygon || []).map(p => `${p.x * scaleX},${p.y * scaleY}`).join(' ')}
                    fill={fillColor} stroke={color} strokeWidth="2"
                  />
                  {z.polygon && z.polygon.length > 0 && (
                    <text x={cx * scaleX} y={cy * scaleY} fill={color} className="font-bold text-sm" textAnchor="middle" dominantBaseline="middle" style={{ textShadow: "0px 1px 3px rgba(0,0,0,0.8)" }}>{z.name}</text>
                  )}
                </g>
              );
            })}
            {currentZone && currentZone.length > 0 && <polyline points={currentZone.map(p => `${p.x * size.w},${p.y * size.h}`).join(' ')} fill="none" stroke="#FFB580" strokeWidth="3" strokeDasharray="4" />}
            {currentZone && currentZone.map((p, i) => <circle key={i} cx={p.x * size.w} cy={p.y * size.h} r="4" fill="#FFB580" />)}
          </svg>
        </div>
      </div>

      <div className="w-full lg:w-80 p-6 space-y-6 bg-slate-50/50">
        <h3 className="text-lg font-bold text-slate-800 border-b border-border pb-3">{t.manageZones}</h3>
        <button onClick={() => setCurrentZone([])} className="btn-primary w-full"><Plus size={18} /> {t.newZone}</button>

        {currentZone !== null && (
          <div className="space-y-3 bg-slate-100 p-4 rounded-xl border border-border">
            <input type="text" placeholder={t.zoneNamePlaceholder} value={zoneName} onChange={e => setZoneName(e.target.value)} className="input-field py-2 text-slate-800" />
            <select value={zoneType} onChange={e => setZoneType(e.target.value)} className="input-field py-2 text-slate-800">
              <option value="safe">{t.safeZone}</option>
              <option value="danger">{t.dangerZone}</option>
            </select>
            <div className="flex gap-2">
              <button onClick={() => { setCurrentZone(null); setZoneName(""); }} className="flex-1 py-2 rounded-xl border border-slate-300 text-slate-500 font-bold hover:bg-slate-200">{t.cancel}</button>
              <button onClick={() => {
                if (zoneName && currentZone.length > 2) {
                  setZones([...zones, { name: zoneName, polygon: currentZone, type: zoneType }]);
                  setCurrentZone(null);
                  setZoneName("");
                  setZoneType("safe");
                } else alert(t.zoneError);
              }} className="flex-1 bg-teal-500 text-teal-50 font-bold py-2 rounded-xl hover:bg-teal-600">{t.addZone}</button>
            </div>
          </div>
        )}

        <div className="space-y-3">
          {zones.map((z, i) => (
            <div key={i} className="flex justify-between items-center bg-slate-100 border border-border p-3 rounded-xl">
              <div className="flex items-center gap-2">
                <div className={`w-3 h-3 rounded-full ${z.type === 'danger' ? 'bg-red-500' : 'bg-teal-500'}`}></div>
                <span className="font-bold text-slate-700">{z.name}</span>
              </div>
              <button onClick={() => setZones(zones.filter((_, idx) => idx !== i))} className="text-red-500 p-2 hover:bg-red-500/10 rounded-lg transition-colors"><Trash2 size={18} /></button>
            </div>
          ))}
          {zones.length === 0 && <p className="text-sm text-slate-500 text-center py-4">{t.noZones}</p>}
        </div>

        <button onClick={saveZones} className="w-full bg-teal-600 hover:opacity-90 text-teal-50 font-bold py-4 rounded-xl flex items-center justify-center gap-2 mt-4 shadow-sm">
          <Save size={20} /> {t.saveFinal}
        </button>
      </div>
    </div>
  );
}

function MedicalViewer({ serverUrl, token, t }) {
  const [medicalData, setMedicalData] = useState({ medications: [], vaccines: [] });
  const [loading, setLoading] = useState(true);
  const [showAddMed, setShowAddMed] = useState(false);
  const [showAddVac, setShowAddVac] = useState(false);
  const [newMed, setNewMed] = useState({ name: '', dose: '', intervalHours: '12', alertEnabled: false });
  const [newVac, setNewVac] = useState({ name: '', dateGiven: '', nextDue: '' });

  useEffect(() => {
    fetch(`${serverUrl}/api/medical?token=${token}`)
      .then(r => r.json())
      .then(d => { setMedicalData(d); setLoading(false); })
      .catch(e => { console.error(e); setLoading(false); });
  }, [serverUrl, token]);

  const handleSave = async (newData) => {
    try {
      await fetch(`${serverUrl}/api/medical?token=${token}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newData)
      });
      setMedicalData(newData)
    } catch (err) { console.error(err); }
  };

  const addMed = () => {
    if (!newMed.name) return;
    const med = { id: crypto.randomUUID(), ...newMed, intervalHours: parseInt(newMed.intervalHours, 10) || 12 };
    const newData = { ...medicalData, medications: [...(medicalData.medications || []), med] };
    handleSave(newData);
    setShowAddMed(false);
    setNewMed({ name: '', dose: '', intervalHours: '12', alertEnabled: false });
  };

  const addVac = () => {
    if (!newVac.name) return;
    const vac = { id: crypto.randomUUID(), ...newVac };
    const newData = { ...medicalData, vaccines: [...(medicalData.vaccines || []), vac] };
    handleSave(newData);
    setShowAddVac(false);
    setNewVac({ name: '', dateGiven: '', nextDue: '' });
  };

  if (loading) return <div className="text-center p-8 text-slate-500 font-medium">{t.loading}...</div>;

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div className="app-card p-6 space-y-4 border-t-4 border-t-teal-500">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="bg-teal-500/10 p-3 rounded-xl text-teal-600"><Heart size={24} /></div>
            <h3 className="text-xl font-bold text-slate-800">{t.medications}</h3>
          </div>
          <button onClick={() => setShowAddMed(true)} className="p-2 bg-teal-50 text-teal-600 rounded-xl hover:bg-teal-100 transition-colors"><Plus size={20} /></button>
        </div>

        {showAddMed && (
          <div className="bg-teal-50/50 p-4 rounded-xl border border-teal-100 space-y-3 mb-4">
            <input type="text" placeholder={t.name} value={newMed.name} onChange={e => setNewMed({ ...newMed, name: e.target.value })} className="input-field py-2" />
            <input type="text" placeholder={t.dose} value={newMed.dose} onChange={e => setNewMed({ ...newMed, dose: e.target.value })} className="input-field py-2" />
            <div className="flex gap-2 items-center">
              <span className="text-sm font-medium text-slate-500">{t.interval} (h):</span>
              <input type="number" value={newMed.intervalHours} onChange={e => setNewMed({ ...newMed, intervalHours: e.target.value })} className="input-field py-1 flex-1" />
            </div>
            <label className="flex items-center gap-2 text-sm text-slate-700 font-medium cursor-pointer">
              <input type="checkbox" checked={newMed.alertEnabled} onChange={e => setNewMed({ ...newMed, alertEnabled: e.target.checked })} className="rounded text-teal-600 focus:ring-teal-500" />
              {t.alertEnabled}
            </label>
            <div className="flex gap-2 pt-2">
              <button onClick={() => setShowAddMed(false)} className="flex-1 py-1.5 rounded-lg border border-slate-300 text-slate-500 font-bold hover:bg-slate-200">{t.cancel}</button>
              <button onClick={addMed} className="flex-1 py-1.5 rounded-lg bg-teal-500 text-white font-bold hover:bg-teal-600">{t.save}</button>
            </div>
          </div>
        )}

        {medicalData.medications?.map((m, i) => (
          <div key={i} className="bg-slate-50 p-4 rounded-xl border border-slate-200 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start">
              <h4 className="font-bold text-slate-800 text-lg mb-1">{m.name}</h4>
              <button onClick={() => handleSave({ ...medicalData, medications: medicalData.medications.filter(x => x.id !== m.id) })} className="text-red-400 hover:text-red-600"><Trash2 size={16} /></button>
            </div>
            <p className="text-sm text-slate-500 font-medium">{t.dose}: <span className="text-slate-700">{m.dose}</span></p>
            <p className="text-sm text-slate-500 font-medium">{t.interval}: <span className="text-slate-700">{m.intervalHours}h</span></p>
            {m.alertEnabled && <p className="text-xs text-teal-600 font-bold mt-3 flex items-center gap-1 bg-teal-50 w-fit px-2 py-1 rounded-md"><Zap size={14} /> {t.alertEnabled}</p>}
          </div>
        ))}
        {(!medicalData.medications || medicalData.medications.length === 0) && <p className="text-slate-400 italic text-center py-4">{t.noData}</p>}
      </div>

      <div className="app-card p-6 space-y-4 border-t-4 border-t-blue-500">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="bg-blue-500/10 p-3 rounded-xl text-blue-600"><Shield size={24} /></div>
            <h3 className="text-xl font-bold text-slate-800">{t.vaccines}</h3>
          </div>
          <button onClick={() => setShowAddVac(true)} className="p-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition-colors"><Plus size={20} /></button>
        </div>

        {showAddVac && (
          <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100 space-y-3 mb-4">
            <input type="text" placeholder={t.name} value={newVac.name} onChange={e => setNewVac({ ...newVac, name: e.target.value })} className="input-field py-2" />
            <div className="grid grid-cols-2 gap-2">
              <div><span className="text-xs text-slate-500 mb-1 block">{t.dateGiven}</span><input type="date" value={newVac.dateGiven} onChange={e => setNewVac({ ...newVac, dateGiven: e.target.value })} className="input-field py-1" /></div>
              <div><span className="text-xs text-slate-500 mb-1 block">{t.nextDue}</span><input type="date" value={newVac.nextDue} onChange={e => setNewVac({ ...newVac, nextDue: e.target.value })} className="input-field py-1" /></div>
            </div>
            <div className="flex gap-2 pt-2">
              <button onClick={() => setShowAddVac(false)} className="flex-1 py-1.5 rounded-lg border border-slate-300 text-slate-500 font-bold hover:bg-slate-200">{t.cancel}</button>
              <button onClick={addVac} className="flex-1 py-1.5 rounded-lg bg-blue-500 text-white font-bold hover:bg-blue-600">{t.save}</button>
            </div>
          </div>
        )}

        {medicalData.vaccines?.map((v, i) => (
          <div key={i} className="bg-slate-50 p-4 rounded-xl border border-slate-200 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start">
              <h4 className="font-bold text-slate-800 text-lg mb-1">{v.name}</h4>
              <button onClick={() => handleSave({ ...medicalData, vaccines: medicalData.vaccines.filter(x => x.id !== v.id) })} className="text-red-400 hover:text-red-600"><Trash2 size={16} /></button>
            </div>
            <p className="text-sm text-slate-500 font-medium">{t.dateGiven}: <span className="text-slate-700">{v.dateGiven}</span></p>
            <p className="text-sm text-slate-500 font-medium">{t.nextDue}: <span className="text-slate-700">{v.nextDue}</span></p>
          </div>
        ))}
        {(!medicalData.vaccines || medicalData.vaccines.length === 0) && <p className="text-slate-400 italic text-center py-4">{t.noData}</p>}
      </div>
    </div>
  );
}

function App() {
  const [lang, setLang] = useState(localStorage.getItem('pettrack_lang') || browserLang);
  const [darkMode, setDarkMode] = useState(localStorage.getItem('pettrack_theme') === 'dark');
  const [token, setToken] = useState(localStorage.getItem('pettrack_token') || '');
  const [serverUrl, setServerUrl] = useState(window.location.origin);
  const [isConfigured, setIsConfigured] = useState(!!localStorage.getItem('pettrack_token'));
  const [inputToken, setInputToken] = useState('');
  const [inputUrl, setInputUrl] = useState(window.location.origin);

  const [appMode, setAppMode] = useState(localStorage.getItem('pettrack_mode'));
  const [activeTab, setActiveTab] = useState('dashboard');

  const [isOnline, setIsOnline] = useState(false);
  const [batteryLevel, setBatteryLevel] = useState(100);
  const [isCharging, setIsCharging] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [petProfile, setPetProfile] = useState(null);
  const [lastSeen, setLastSeen] = useState("--");
  const [mostSeen, setMostSeen] = useState("--");
  const [frameUrl, setFrameUrl] = useState(null);
  const [eventLog, setEventLog] = useState([]);

  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const lastNotifiedEventRef = useRef(null);

  // A Vite Proxy miatt a webes kliens MINDIG a saját maga címét (window.location.origin) használja a backend eléréséhez!
  const actualServerUrl = window.location.origin;

  const handleConnect = () => {
    if (inputToken) {
      localStorage.setItem('pettrack_token', inputToken);
      localStorage.setItem('pettrack_url', actualServerUrl);
      setToken(inputToken);
      setServerUrl(actualServerUrl);
      setIsConfigured(true);
    }
  };

  const t = locales[lang] || locales.en;

  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('pettrack_theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('pettrack_theme', 'light');
    }
  }, [darkMode]);

  const toggleLang = () => {
    const newLang = lang === 'hu' ? 'en' : 'hu';
    setLang(newLang);
    localStorage.setItem('pettrack_lang', newLang);
  };

  // 1. lépés: Szerver státusz és akkumulátor
  useEffect(() => {
    if (!isConfigured || !token || !serverUrl || appMode !== 'client') return;

    const fetchStatus = async () => {
      try {
        const respose = await fetch(`${serverUrl}/api/status?token=${token}`);
        if (respose.ok) {
          const data = await respose.json();
          setIsOnline(data.monitor_online);
          if (data.battery_level !== undefined) setBatteryLevel(data.battery_level);
          if (data.is_charging !== undefined) setIsCharging(data.is_charging);
        } else {
          setIsOnline(false);
        }
      } catch (error) {
        setIsOnline(false);
      }
    };

    fetchStatus();
    const interval = setInterval(fetchStatus, 3000);
    return () => clearInterval(interval);
  }, [isConfigured, token, serverUrl, appMode]);

  // 2. lépés: Profil, Last Seen, Most Seen, Eseménynapló
  useEffect(() => {
    if (!isConfigured || !token || !serverUrl || appMode !== 'client') return;

    const fetchAdditionalData = async () => {
      try {
        const [petRes, activityRes] = await Promise.all([
          fetch(`${serverUrl}/api/pet?token=${token}`),
          fetch(`${serverUrl}/api/activity?token=${token}`)
        ]);
        if (petRes.ok) setPetProfile(await petRes.json());
        if (activityRes.ok) {
          const { events } = await activityRes.json();
          setEventLog(events || []);
          if (events && events.length > 0) {
            const latestEvent = events[0];

            if (Notification.permission === 'granted') {
              if (lastNotifiedEventRef.current && lastNotifiedEventRef.current < latestEvent.timestamp) {
                const eventTypeHu = latestEvent.event_type === 'movement' ? t.eventMovement :
                  latestEvent.event_type === 'zone_enter' ? t.eventZoneEnter :
                    latestEvent.event_type === 'zone_exit' ? t.eventZoneExit : latestEvent.event_type;
                new Notification('PetTrack értesítés', {
                  body: `${eventTypeHu} ${latestEvent.zone_name ? `- ${latestEvent.zone_name}` : ''}`
                });
                lastNotifiedEventRef.current = latestEvent.timestamp;
              } else if (Notification.permission !== 'denied') {
                Notification.requestPermission();
              }
            }

            const date = new Date(latestEvent.timestamp * 1000);
            setLastSeen(date.toLocaleTimeString('hu-HU', { hour: '2-digit', minute: '2-digit' }) + (latestEvent.zone_name ? ` (${latestEvent.zone_name})` : ''));

            const zoneCounts = {};
            events.forEach(e => {
              if (e.zone_name) {
                zoneCounts[e.zone_name] = (zoneCounts[e.zone_name] || 0) + 1;
              }
            });
            const sortedZones = Object.entries(zoneCounts).sort((a, b) => b[1] - a[1]);
            setMostSeen(sortedZones.length > 0 ? sortedZones[0][0] : '--');
          }
        }
      } catch (err) {
        console.error("Hiba az adatok lekérésekor:", err);
      }
    };

    fetchAdditionalData();
    const interval = setInterval(fetchAdditionalData, 10000);
    return () => clearInterval(interval);
  }, [isConfigured, token, serverUrl, appMode]);

  // 3. lépés: Videó képkockák (5 FPS) és WebSocket trigger
  useEffect(() => {
    if (!isConfigured || !token || !serverUrl || appMode !== 'client' || !isOnline) return;
    const updateFrame = () => {
      setFrameUrl(`${serverUrl}/api/frame/web?token=${token}&ts=${Date.now()}`);
    };
    updateFrame();
    const interval = setInterval(updateFrame, 200); // 5 FPS

    // Kinyitjuk a WebSocktet, hogy a Python backend felgyorsítsa a kamerát 5 FPS-re
    const wsUrl = serverUrl.replace('http', 'ws');
    const ws = new WebSocket(`${wsUrl}/ws/client?token=${token}`);
    ws.onerror = () => { };

    return () => { clearInterval(interval); ws.close(); };
  }, [isConfigured, token, serverUrl, isOnline, appMode]);

  useEffect(() => {
    if (!isConfigured || !token || !serverUrl || appMode !== 'monitor') return;

    let ws = null;
    let stream = null;
    let interval = null;

    const startMonitor = async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }

        const clientId = `monitor_${Math.random().toString().substr(2, 9)}`;

        // WebSocket helyett HTTP POST a képkockák küldéséhez (Safari self-signed HTTPS kompatibilitás miatt)
        interval = setInterval(() => {
          if (videoRef.current && canvasRef.current) {
            const context = canvasRef.current.getContext('2d');
            canvasRef.current.width = videoRef.current.videoWidth || 640;
            canvasRef.current.height = videoRef.current.videoHeight || 480;
            if (canvasRef.current.width > 0 && canvasRef.current.height > 0) {
              context.drawImage(videoRef.current, 0, 0, canvasRef.current.width, canvasRef.current.height);
              canvasRef.current.toBlob((blob) => {
                if (blob) {
                  fetch(`${serverUrl}/api/frame/web?token=${token}&client_id=${clientId}`, {
                    method: 'POST',
                    body: blob
                  }).catch(() => { });
                }
              }, 'image/jpeg', 0.8);
            }
          }
        }, 200);
      } catch (err) {
        console.error("Camera access error:", err);
        alert(t.errorMedia);
      }
    };

    startMonitor();

    return () => {
      if (interval) clearInterval(interval);
      if (stream) stream.getTracks().forEach(track => track.stop());
    };
  }, [isConfigured, token, serverUrl, appMode, t.errorMedia]);

  useEffect(() => {
    if (!isConfigured || !token || !serverUrl || appMode !== 'monitor') return;

    let interval = null;
    const updateBattery = async () => {
      try {
        let level = 100;
        let charging = false;
        if (navigator.getBattery) {
          const battery = await navigator.getBattery();
          level = Math.round(battery.level * 100);
          charging = battery.charging;
        }
        await fetch(`${serverUrl}/api/monitor/update?token=${token}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ battery_level: level, is_charging: charging })
        });
      } catch (err) {
        console.error("Battery update error:", err);
      }
    };

    updateBattery();
    interval = setInterval(updateBattery, 10000);
    return () => clearInterval(interval);
  }, [isConfigured, token, serverUrl, appMode]);

  const handleSaveToken = (e) => {
    e.preventDefault();
    if (inputToken.trim() && inputUrl.trim()) {
      localStorage.setItem('pettrack_token', inputToken.trim());
      localStorage.setItem('pettrack_url', inputUrl.trim());
      setToken(inputToken.trim());
      setServerUrl(inputUrl.trim());
      setIsConfigured(true);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('pettrack_token');
    localStorage.removeItem('pettrack_mode');
    setToken('');
    setAppMode(null);
    setIsConfigured(false);
  };

  const handleSaveProfile = async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const name = formData.get('name');
    const type = formData.get('type');
    const picFile = formData.get('profile_pic');

    let base64Pic = petProfile?.profile_pic;
    if (picFile && picFile.size > 0) {
      const buffer = await picFile.arrayBuffer();
      const uint8Array = new Uint8Array(buffer);
      let binary = '';
      for (let i = 0; i < uint8Array.byteLength; i++) {
        binary += String.fromCharCode(uint8Array[i]);
      }
      base64Pic = btoa(binary);
    }
    try {
      await fetch(`${serverUrl}/api/pet?token=${token}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, type, profile_pic: base64Pic })
      });
      alert(t.saveSuccess);
    } catch (err) {
      console.error(err);
    }
  };

  const resetRole = () => {
    localStorage.removeItem('pettrack_mode');
    setAppMode(null);
  };

  if (!isConfigured) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100">
        <div className="app-card w-full max-w-sm text-center p-8 animate-fade-in">
          <div className="flex justify-center mb-6">
            <div className="bg-teal-500/10 p-4 rounded-full text-teal-600">
              <Shield size={48} />
            </div>
          </div>
          <h2 className="text-2xl font-bold mb-2">{t.welcome}</h2>
          <p className="text-slate-500 mb-6">
            {t.enterUrl} <br /> {t.enterToken}
          </p>

          <form onSubmit={handleSaveToken} className="space-y-4">
            <input
              type="text"
              className="input-field"
              placeholder={t.placeholderUrl}
              value={inputUrl}
              onChange={(e) => setInputUrl(e.target.value)}
            />
            <input
              type="password"
              className="input-field"
              placeholder={t.placeholderToken}
              value={inputToken}
              onChange={(e) => setInputToken(e.target.value)}
            />
            <button type="submit" className="btn-primary w-full" disabled={!inputToken.trim() || !inputUrl.trim()}>
              {t.connect}
            </button>
          </form>
        </div>
      </div>
    );
  }

  if (!appMode) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100">
        <div className="app-card w-full max-w-md p-8 animate-fade-in text-center">
          <h2 className="text-2xl font-bold mb-8 text-slate-800">{t.chooseRole}</h2>
          <div className="space-y-4">
            <button
              onClick={() => { localStorage.setItem('pettrack_mode', 'monitor'); setAppMode('monitor'); }}
              className="w-full bg.white border-2 border-teal-500 text-teal-600 hover:bg-teal-50 p-6 rounded-2xl flex flex-col items-center gap-3 transition-all">
              <Zap size={40} />
              <span className="font-bold text-lg">{t.roleMonitor}</span>
              <span className="text-sm font-medium opacity-80">{t.roleMonitorDesc}</span>
            </button>
            <button
              onClick={() => { localStorage.setItem('pettrack_mode', 'client'); setAppMode('client'); }}
              className="w-full bg-white border-2 border-slate-300 text-slate-600 hover:border-slate-400 hover:bg-slate-50 p-6 rounded-2xl flex flex-col items-center gap-3 transition-all">
              <User size={40} />
              <span className="font-bold text-lg">{t.roleClient}</span>
              <span className="text-sm font-medium opacity-80">{t.roleClientDesc}</span>
            </button>
          </div>
          <button onClick={handleLogout} className="mt-8 text-slate-400 hover:text-slate-600 font-medium text-sm">
            {t.logout}
          </button>
        </div>
      </div>
    )
  };

  if (appMode === "monitor") {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-slate-900 text-white">
        <div className="w-full max-w-2xl relative bg-black rounded-3xl overflow-hidden shadow-2xl border-4 border-slate-800">
          <video ref={videoRef} autoPlay playsInline muted className="w-full aspect-video object-cover" />
          <canvas ref={canvasRef} className="hidden" />

          <div className="absolute top-0 left-0 w-full p-4 flex justify-between items-start bg-gradient-to-b from-black/80 to-transparent">
            <div className="flex items-center gap-2 text-teal-400 px-3 py-1.5 rounded-full backdrop-blur-md">
              <span className="font-bold text-sm">{t.monitorActive}</span>
            </div>
            <button onClick={resetRole} className="bg-red-500 hover:bg-red-600 text-white p-2 rounded-full shadow-lg transition-transform hover:scale-105">
              <X size={20} />
            </button>
          </div>

          <div className="absolute bottom-4 left-4 right-4 text-center text-xs text-slate-400 bg-black/40 p-2 rounded-xl backdrop-blur-md">
            {t.monitorStreaming}
          </div>
        </div>
      </div>
    );
  }


  return (
    <div className="h-screen flex w-full relative overflow-hidden bg-slate-50 dark:bg-slate-900 dark:text-slate-100">
      {/* Mobile Menu Overlay */}
      {isMobileMenuOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 md:hidden backdrop-blur-sm transition-opacity"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`fixed inset-y-0 left-0 z-50 w-64 bg-slate-100 border-r border-slate-200 p-4 flex flex-col transform transform-transform duration-300 md:relative md:translate-x-0 ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div className="flex justify-between items-center mb-8 mt-2 px-2">
          <div className="flex items-center gap-3">
            <div className="bg-teal-500 p-2 rounded-xl text-white shadow-sm shadow-teal-500/20">
              <Shield size={24} />
            </div>
            <div>
              <h1 className="font-bold text-xl text-slate-800 leading-tight">{t.appTitle}</h1>
              <p className="text-xs text-slate-500">{t.appSubtitle}</p>
            </div>
          </div>
          <button className="md:hidden text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100" onClick={() => setIsMobileMenuOpen(false)}>
            <X size={20} />
          </button>
        </div>

        <nav className="flex-1 space-y-2">
          <button onClick={() => setActiveTab('dashboard')} className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-all ${activeTab === 'dashboard' ? 'bg-brand-primary text-teal-50' : 'text-slate-500 hover:bg-slate-100 hover:text-slate-800'}`}>
            <LayoutDashboard size={20} />
            {t.dashboard}
          </button>
          <button onClick={() => setActiveTab('zones')} className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-all ${activeTab === 'zones' ? 'bg-brand-primary text-teal-50' : 'text-slate-500 hover:bg-slate-100 hover:text-slate-800'}`}>
            <Map size={20} />
            {t.manageZones || "Zónák"}
          </button>
          <button onClick={() => setActiveTab('medical')} className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-all ${activeTab === 'medical' ? 'bg-brand-primary text-teal-50' : 'text-slate-500 hover:bg-slate-100 hover:text-slate-800'}`}>
            <Heart size={20} />
            {t.manageMedical}
          </button>
          <button onClick={() => setActiveTab('settings')} className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-all ${activeTab === 'settings' ? 'bg-brand-primary text-teal-50' : 'text-slate-500 hover:bg-slate-100 hover:text-slate-800'}`}>
            <Settings size={20} />
            {t.settings}
          </button>
        </nav>
        <div className="space-y-2 pt-4 border-t border-slate-100 mt-auto">
          <button onClick={handleLogout} className="w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium text-slate-600 hover:bg-slate-50 transition-all">
            <LogOut size={20} />
            {t.logout}
          </button>
        </div>
      </aside>

      <main className="flex-1 p-4 md:p-8 overflow-y-auto w-full flex justify-center">
        <div className="w-full max-w-screen-2xl">
          <header className="flex justify-between items-start mb-8">
            <div className="flex items-center gap-3">
              <button className="md:hidden p-2 -ml-2 rounded-lg text-slate-600 hover:bg-slate-100 transition-colors" onClick={() => setIsMobileMenuOpen(true)}>
                <Menu size={24} />
              </button>
              <div>
                <h2 className="text-2xl font-bold text-slate-800 mb-1">{t.dashboard}</h2>
                <p className="text-sm text-slate-500">{t.lastUpdate}: {t.now}</p>
              </div>
            </div>
            <div className="flex items-center gap-3 md:gap-4">
              <div className="hidden sm-flex items-center gap-2 px-3 py-1.5 bg-slate-100 border border-slate-200 rounded-full text-slate-700 shadow-sm">
                {isCharging ? <BatteryCharging size={18} className="text-emerald-500" /> : <Battery size={18} className={batteryLevel > 20 ? 'text-teal-500' : 'text-red-500'} />}
                <span className="text-sm font-bold">{batteryLevel}%</span>
              </div>
              {/* <button onClick={() => setDarkMode(!darkMode)} className="p-2 rounded-full border border-slate-200 text-slate-600 dark:text-slate-300 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                {darkMode ? <Sun size={20} /> : <Moon size={20} />}
              </button> */ }
              <button onClick={toggleLang} className="p-2 rounded-full border border-slate-200 text-slate-600 dark:text-slate-300 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 font-bold text-sm transition-all">
                {lang.toUpperCase()}
              </button>
            </div>
          </header>

          {activeTab === 'dashboard' ? (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Left Column */}
              <div className="lg:col-span-2 space-y-6">
                {/* Video Feed */}
                <div className="rounded-2xl shadow-sm border border-slate-800 overflow-hidden relative w-full aspect-video bg-slate-900 flex flex-col items-center justify-center group">
                  <div className="absolute top-4 left-4 z-10">
                    <div className="bg-black/50 backdrop-blur-sm px-3 py-1.5 rounded-full flex items-center gap-2 text-xs font-semibold text-white">
                      {isOnline ? (
                        <><div className="w-2 h-2 rounded-full bg-red-500 animate-pulse" /> {t.live}</>
                      ) : (
                        <><WifiOff size={14} className="text-slate-400" /> {t.offline}</>
                      )}
                    </div>
                  </div>

                  {frameUrl ? (
                    <img
                      src={frameUrl}
                      alt="Live Camera Feed"
                      className="w-full h-full object-cover z-0"
                    />
                  ) : (
                    <div className="text-slate-400 text-center z-0 transition-opacity duration-300">
                      <Wifi size={48} className="mx-auto mb-4 opacity-50" />
                      <p>{t.camConnecting}</p>
                    </div>
                  )}

                  <div className="absolute bottom-4 left-4 right-4 flex justify-between items-end z-10">
                    <div className="bg-gradient-to-t from-black/80 via-black/40 to-transparent absolute -inset-4 p-8 pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                    <div className="relative">
                      <h3 className="text-white font-semibold text-lg drop-shadow-md">{t.camView}</h3>
                      <p className="text-white/80 text-sm drop-shadow-md">{t.camWaiting}</p>
                    </div>
                  </div>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div className="app-card p-6 flex items-center justify-between group hover:border-teal-200 transition-colors">
                    <div>
                      <p className="text-xs font-semibold tracking-wider text-slate-500 uppercase mb-1">{t.lastSeen}</p>
                      <div className="flex items-baseline gap-1">
                        <span className="text-2xl font-bold text-slate-800">{lastSeen !== '--' ? lastSeen : '--'}</span>
                      </div>
                      {lastSeen === '--' && <p className="text-xs text-slate-400 mt-1">{t.noData}</p>}
                    </div>
                    <div className="w-16 h-16 rounded-full border-4 border-teal-100 flex items-center justify-center text-teal-500 group-hover:scale-110 group-hover:border-teal-200 transition-all duration-300">
                      <Clock size={24} />
                    </div>
                  </div>

                  <div className="app-card p-6 flex items-center justify-between group hover:border-orange-200 transition-colors">
                    <div>
                      <p className="text-xs font-semibold tracking-wider text-slate-500 uppercase mb-1">{t.mostSeen}</p>
                      <div className="flex items-baseline gap-1">
                        <span className="text-2xl font-bold text-slate-800">{mostSeen}</span>
                      </div>
                      {mostSeen === '--' && <p className="text-xs text-slate-400 mt-1">{t.noData}</p>}
                    </div>
                    <div className="w-16 h-16 rounded-full border-4 border-orange-100 flex items-center justify-center text-orange-400 group-hover:scale-110 group-hover:border-orange-200 transition-all duration-300">
                      <Moon size={24} />
                    </div>
                  </div>
                </div>
              </div>

              {/* Right Column */}
              <div className="space-y-6">
                {/* Profile Placeholder */}
                <div className="app-card overflow-hidden">
                  <div className="h-24 bg-teal-500/90 relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-tr from-teal-600 to-transparent" />
                  </div>
                  <div className="px-6 pb-6 relative text-center">
                    <div className="w-20 h-20 bg-slate-100 rounded-full border-4 border-white mx-auto -mt-10 mb-3 flex items-center justify-center text-slate-400 shadow-sm overflow-hidden">
                      {petProfile?.profile_pic ? (
                        <img src={`data:image/jpeg;base64,${petProfile.profile_pic}`} className="w-full h-full object-cover" alt="Pet" />
                      ) : (
                        <User size={32} />
                      )}
                    </div>
                    <h3 className="text-xl font-bold text-slate-800">{petProfile?.name || t.profile}</h3>
                    <p className="text-sm text-slate-500 mb-4">
                      {petProfile?.type ? (t.petTypes[petProfile.type] || petProfile.type) : t.loadingData}
                    </p>
                    <div className="inline-flex items-center gap-1 bg-slate-50 border border-slate-100 text-slate-600 px-3 py-1 rounded-full text-sm font-medium">
                      <Clock size={16} />
                      <span>--</span>
                    </div>
                  </div>
                </div>

                {/* Event Log Placeholder */}
                <div className="app-card p-6">
                  <div className="flex justify-between items-center mb-6">
                    <h3 className="font-bold text-slate-800 leading-tight">{t.eventLog}</h3>
                    <Clock size={20} className="text-slate-400" />
                  </div>
                  <div className="space-y-4 max-h-64 overflow-y-auto pr-2 custom-scrollbar">
                    {eventLog.length > 0 ? (
                      eventLog.map((event, idx) => (
                        <div key={idx} className="flex flex-col gap-1 border-b border-slate-100 pb-3 last:border-0">
                          <span className="text-xs text-slate-400 font-medium tracking-wide">
                            {new Date(event.timestamp * 1000).toLocaleTimeString('hu-HU')}
                          </span>
                          <span className="text-sm text-slate-700 font-semibold">
                            {event.event_type === 'movement' ? t.eventMovement :
                              event.event_type === 'zone_enter' ? t.eventZoneEnter :
                                event.event_type === 'zone_exit' ? t.eventZoneExit : event.event_type}
                            {event.zone_name ? ` - ${event.zone_name}` : ''}
                          </span>
                        </div>
                      ))
                    ) : (
                      <p className="text-sm text-slate-500 text-center py-8 bg-slate-50 rounded-xl border border-dashed border-slate-200">{t.noEvents}</p>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ) : activeTab === 'zones' ? (
            <ZoneEditor serverUrl={serverUrl} token={token} frameUrl={frameUrl} t={t} />
          ) : activeTab === 'medical' ? (
            <MedicalViewer serverUrl={serverUrl} token={token} t={t} />
          ) : (
            <div className="max-w-2xl mx-auto space-y-6">
              <div className="app-card p-6">
                <h3 className="text-xl font-bold mb-4">{t.profile}</h3>
                <form className="space-y-4" onSubmit={handleSaveProfile}>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">{t.petName}</label>
                    <input name="name" type="text" defaultValue={petProfile?.name || ''} className="input-field" placeholder="" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">{t.petType}</label>
                    <select name="type" defaultValue={petProfile?.type || 'other'} className="input-field">
                      {Object.entries(t.petTypes).map(([key, val]) => (
                        <option key={key} value={key}>{val}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">{t.uploadPicture}</label>
                    <input name="profile_pic" type="file" accept="image/*" className="input-field py-2" />
                  </div>
                  <button type="submit" className="btn-primary w-full">{t.save}</button>
                </form>
              </div>

              <div className="app-card p-6 border border-red-900/30 bg-red-500/5">
                <h3 className="text-xl font-bold text-red-500 mb-4">{t.deviceSettings}</h3>
                <p className="text-sm text-slate-400 mb-4">
                  {t.deviceSettingsDesc}
                </p>
                <button onClick={resetRole} className="w-full border border-red-500/50 text-red-400 hover:bg-red-500/10 p-3 rounded-xl font-bold transition-colors">
                  {t.resetRole}
                </button>
              </div>
            </div>
          )}
        </div>
      </main >
    </div >
  );
}
export default App;