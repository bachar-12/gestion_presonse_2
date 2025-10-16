import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();
const db = admin.firestore();

// Callable: verify a session code for QR flow
// Params: { sessionId: string, code: string }
export const verifySessionCode = functions.https.onCall(async (data, context) => {
  const { sessionId, code } = data || {};
  if (!sessionId || !code) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing sessionId or code');
  }
  const snap = await db.collection('sessions').doc(sessionId).get();
  if (!snap.exists) return { ok: false };
  const expected = snap.get('code');
  return { ok: expected === code };
});

// Firestore trigger: when an attendance is created with status 'absent',
// send a notification to the student if a token is available
export const onAttendanceCreate = functions.firestore
  .document('attendances/{attendanceId}')
  .onCreate(async (snap, _ctx) => {
    const data = snap.data();
    if (!data) return;
    if (data.status !== 'absent') return;
    const studentId: string = data.studentId;
    // expect token stored under users/{uid}.fcmToken
    const userDoc = await db.collection('users').doc(studentId).get();
    const token = userDoc.get('fcmToken');
    if (!token) return;
    const message: admin.messaging.Message = {
      token,
      notification: {
        title: 'Absence détectée',
        body: 'Vous avez été marqué absent à une séance.',
      },
      data: {
        type: 'absence',
        sessionId: data.sessionId || '',
      },
    };
    await admin.messaging().send(message);
  });

// Scheduled job (skeleton): compute repeated absences and notify the teacher
// You must configure scheduler in your Firebase project before deploying.
// Example (commented):
// export const checkRepeatedAbsences = functions.pubsub
//   .schedule('every 24 hours')
//   .timeZone('UTC')
//   .onRun(async (_ctx) => {
//     // TODO: aggregate absences per class/student and notify teacher if threshold is reached
//   });

