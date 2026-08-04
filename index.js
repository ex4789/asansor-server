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
    console.error('Veri okuma hatası:', e);
  }
  return [];
}

function veriYaz(veri) {
  fs.writeFileSync(VERI_DOSYASI, JSON.stringify(veri, null, 2), 'utf8');
}

app.get('/', (req, res) => {
  res.send('Sunucu canavar gibi calisiyor reis!');
});

// Tüm bina kayıtlarını getir
app.get('/binalar', (req, res) => {
  const veri = veriOku();
  res.json(veri);
});

// Tüm bina kayıtlarını kaydet (uygulama her değişiklikte tüm listeyi gönderir)
app.post('/binalar', (req, res) => {
  const yeniVeri = req.body;
  if