var exec = require('cordova/exec');

function FontDownloader() {
    this.listeners = {
        begin: [],
        finish: [],
        begindownloading: [],
        match: [],
        beginquerying: [],
        begindownloading: [],
        finishdownloading: [],
        downloading: [],
        fail: [],
        stalled: []
    };
}

FontDownloader.prototype.download = function(fontName) {
    var dispatch = this.dispatch.bind(this);

    exec(dispatch, dispatch, 'FontDownloader', 'download', [fontName]);
}

FontDownloader.prototype.dispatch = function(event) {
    var listeners = this.listeners[event.type];
    if (listeners) {
        for (var i = 0; i < listeners.length; i++) {
            listeners[i](event);
        }
    }
}

FontDownloader.prototype.addListener = function(type, listener) {
    var listeners = this.listeners[type];
    if (listeners) {
        listeners.push(listener);
    }
}

FontDownloader.prototype.removeListener = function(type, listener) {
    var listeners = this.listeners[type];
    if (listeners) {
        var index = listeners.indexOf(listener);
        if (index > -1) {
            listeners.splice(index, 1);
        }
    }
}

module.exports = FontDownloader;
