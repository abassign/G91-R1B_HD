#temporary script;

var versions      = ["v1.0", "v1.1"];
var version_items = {};

version_items["v1.0"] = {
	"category"    : 0,
	"popupTip"    : 1,
	"dialog-show" : 0,
	"dialog-name" : "",
};
version_items["v1.1"] = {
	"panel-show"          : 0,
	"enable-head-tracker" : 0,
};

var create_version_vector = func (v) {
	if (v == "v1.0") return ["v1.0", "v1.1"];
	if (v == "v1.1") return ["v1.1"];
}

var update_cam_version = func (v) {
	var vec = create_version_vector(v);
	foreach (var _v; vec)
		foreach ( var item; keys(version_items[_v]) )
			forindex (var i; cameras)
				cameras[i][item] = version_items[_v][item];
};

print("Version script loaded");