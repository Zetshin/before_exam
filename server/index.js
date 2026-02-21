const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.SERVER_PORT || 3000;

// แปลง Date object หรือ ISO string เป็น YYYY-MM-DD HH:MM:SS
function formatTimestamp(ts) {
    if (!ts) return null;
    const d = new Date(ts);
    if (isNaN(d.getTime())) return ts;
    const pad = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

// แปลง timestamp ในแต่ละ row ให้เป็น format ที่ถูกต้อง
function formatReportRows(rows) {
    return rows.map(row => ({
        ...row,
        timestamp: formatTimestamp(row.timestamp)
    }));
}

// ==================== Polling Stations ====================

// GET /stations - ดึงหน่วยเลือกตั้งทั้งหมด
app.get('/stations', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM polling_station');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /stations/:id - ดึงหน่วยเลือกตั้งตาม ID
app.get('/stations/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM polling_station WHERE station_id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Station not found' });
        }
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==================== Violation Types ====================

// GET /violation-types - ดึงประเภทการทุจริตทั้งหมด
app.get('/violation-types', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM violation_type');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /violation-types/:id - ดึงประเภทการทุจริตตาม ID
app.get('/violation-types/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM violation_type WHERE type_id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Violation type not found' });
        }
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==================== Incident Reports ====================

// GET /reports - ดึงรายงานทั้งหมด (JOIN station + type)
app.get('/reports', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT r.*, 
                   s.station_name, s.zone, s.province,
                   v.type_name, v.severity
            FROM incident_report r
            LEFT JOIN polling_station s ON r.station_id = s.station_id
            LEFT JOIN violation_type v ON r.type_id = v.type_id
            ORDER BY r.report_id DESC
        `);
        res.json(formatReportRows(rows));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /reports/:id - ดึงรายงานเดี่ยว
app.get('/reports/:id', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT r.*, 
                   s.station_name, s.zone, s.province,
                   v.type_name, v.severity
            FROM incident_report r
            LEFT JOIN polling_station s ON r.station_id = s.station_id
            LEFT JOIN violation_type v ON r.type_id = v.type_id
            WHERE r.report_id = ?
        `, [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Report not found' });
        }
        const formatted = formatReportRows(rows);
        res.json(formatted[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /reports - สร้างรายงานใหม่
app.post('/reports', async (req, res) => {
    try {
        const { station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence } = req.body;
        const formattedTs = formatTimestamp(timestamp);
        const [result] = await pool.query(
            `INSERT INTO incident_report (station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [station_id, type_id, reporter_name, description || null, evidence_photo || null, formattedTs, ai_result || null, ai_confidence || 0.0]
        );
        const [newReport] = await pool.query('SELECT * FROM incident_report WHERE report_id = ?', [result.insertId]);
        res.status(201).json(formatReportRows(newReport)[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /reports/:id - แก้ไขรายงาน
app.put('/reports/:id', async (req, res) => {
    try {
        const { station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence } = req.body;
        const formattedTs = formatTimestamp(timestamp);
        const [result] = await pool.query(
            `UPDATE incident_report 
             SET station_id = ?, type_id = ?, reporter_name = ?, description = ?, evidence_photo = ?, timestamp = ?, ai_result = ?, ai_confidence = ?
             WHERE report_id = ?`,
            [station_id, type_id, reporter_name, description || null, evidence_photo || null, formattedTs, ai_result || null, ai_confidence || 0.0, req.params.id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Report not found' });
        }
        const [updated] = await pool.query('SELECT * FROM incident_report WHERE report_id = ?', [req.params.id]);
        res.json(formatReportRows(updated)[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE /reports/:id - ลบรายงาน
app.delete('/reports/:id', async (req, res) => {
    try {
        const [result] = await pool.query('DELETE FROM incident_report WHERE report_id = ?', [req.params.id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Report not found' });
        }
        res.json({ message: 'Report deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==================== Start Server ====================
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

