const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();

app.use(cors());
app.use(express.json({ limit: '10mb' }));

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

app.get('/', (req, res) => {
  res.send('Sunucu canavar gibi calisiyor reis!');
});

// Tum bina kayitlarini getir
app.get('/binalar', async (req, res) => {
  const { data, error } = await supabase
    .from('binalar_veri')
    .select('icerik')
    .eq('id', 1)
    .single();

  if (error) {
    console.error('Supabase okuma hatasi:', error);
    return res.status(500).json({ hata: 'Veri okunamadi' });
  }

  res.json(data.icerik || []);
});

// Tum bina kayitlarini kaydet
app.post('/binalar', async (req, res) => {
  console.log('POST /binalar istegi geldi! Zaman:', new Date().toISOString());
  const yeniVeri = req.body;

  if (!Array.isArray(yeniVeri)) {
    return res.status(400).json({ hata: 'Veri bir liste (array) olmali' });
  }

  const { error } = await supabase
    .from('binalar_veri')
    .update({ icerik: yeniVeri })
    .eq('id', 1);

  if (error) {
    console.error('Supabase yazma hatasi:', error);
    return res.status(500).json({ hata: 'Veri kaydedilemedi' });
  }

  res.json({ basarili: true, kayitSayisi: yeniVeri.length });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, function () {
  console.log('Sunucu ' + PORT + ' portunda hazir...');
});