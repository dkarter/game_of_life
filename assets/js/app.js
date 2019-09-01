import '../css/app.css';

import 'phoenix_html';

import LiveSocket from 'phoenix_live_view';

const liveSocket = new LiveSocket('/live');
liveSocket.connect();
