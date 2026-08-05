const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json({ limit: '10mb' }));

const VERI_DOSYASI = path.join(__dirname, 'data.json');

function veriOku() {
  try {
    if (fs.existsSync(VERI_DOSYASI)) {
      const ham = fs.readFileSync(VERI_DOSYASI, 'utf8');
      return JSON.parse(ham);
    }
  } catch (e) {
    console.error('Veri okuma hatasi:', e);
  }
  return [];
}

function veriYaz(veri) {
  fs.writeFileSync(VERI_DOSYASI, JSON.stringify(veri, null, 2), 'utf8');
}

app.get('/', (req, res) => {
  res.send('Sunucu canavar gibi calisiyor reis!');
});

app.get('/binalar', (req, res) => {
  const veri = veriOku();
  res.json(veri);
});

app.post('/binalar', (req, res) => {
  console.log('POST /binalar istegi geldi! Zaman:', new Date().toISOString());
  const yeniVeri = req.body;
  if (!Array.isArray(yeniVeri)) {
    return res.status(400).json({ hata: 'Veri bir liste (array) olmali' });
  }
  veriYaz(yeniVeri);
  res.json({ basarili: true, kayitSayisi: yeniVeri.length });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, function () {
  console.log('Sunucu ' + PORT + ' portunda hazir...');
});