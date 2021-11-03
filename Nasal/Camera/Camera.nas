# Camera utility mobile views

var prop = props.globals.initNode("sim/G91/camera/to/set-position","0,0.0,0.0,0.0,0.0,0.0,0.0", "STRING");


var ViewCamDataClass = {
    class_name: "ViewCamDataClass",

    new: func() {
        var obj = {
            view_number: 0,
            field_of_view: 0.0,
            heading_offset_deg: 0.0,
            pitch_offset_deg: 0.0,
            x_offset: 0.0,
            y_offset: 0.0,
            z_offset: 0.0,
        };
        return {parents: [ViewCamDataClass]};
    },

    init: func(view_number,field_of_view,heading_offset,pitch_offset,x_offset,y_offset,z_offset) {
        me.view_number = view_number;
        me.field_of_view = field_of_view;
        me.heading_offset_deg = heading_offset;
        me.pitch_offset_deg = pitch_offset;
        me.x_offset = x_offset;
        me.y_offset = y_offset;
        me.z_offset = z_offset;
    },

    difDegNorm: func(fromAng,toAng,stepRemain) {
        a1 = fromAng;
        a2 = toAng;
        fromAngRad = fromAng * 0.0174533;
        toAngRad = toAng * 0.0174533;
        difRad = math.asin(math.sin(toAngRad) * math.cos(fromAngRad) - math.cos(toAngRad) * math.sin(fromAngRad)) / stepRemain;
        value = math.asin(math.sin(toAngRad) * math.cos(difRad) + math.cos(toAngRad) * math.sin(difRad)) / 0.0174533;
        return value;
    },

    getView: func() {
        me.view_number = getprop("/sim/current-view/view-number");
        me.field_of_view = getprop("/sim/current-view/field-of-view");
        me.heading_offset_deg = getprop("/sim/current-view/heading-offset-deg");
        me.pitch_offset_deg = getprop("/sim/current-view/pitch-offset-deg");
        me.x_offset = getprop("/sim/current-view/x-offset-m");
        me.y_offset = getprop("/sim/current-view/y-offset-m");
        me.z_offset = getprop("/sim/current-view/z-offset-m");
    },

    setView: func() {
        setprop("/sim/current-view/view-number",me.view_number);
        setprop("/sim/current-view/field-of-view",me.field_of_view);
        setprop("/sim/current-view/heading-offset-deg",me.heading_offset_deg);
        setprop("/sim/current-view/pitch-offset-deg",me.pitch_offset_deg);
        setprop("/sim/current-view/x-offset-m",me.x_offset);
        setprop("/sim/current-view/y-offset-m",me.y_offset);
        setprop("/sim/current-view/z-offset-m",me.z_offset);
    },

    goViewTo: func(to,stepRemain) {
        me.getView();
        me.view_number = to.view_number;
        me.field_of_view = me.field_of_view + (to.field_of_view - me.field_of_view)/stepRemain;
        me.heading_offset_deg = me.difDegNorm(me.heading_offset_deg,to.heading_offset_deg,stepRemain);
        me.pitch_offset_deg = me.difDegNorm(me.pitch_offset_deg,to.pitch_offset_deg,stepRemain);
        me.x_offset = me.x_offset + (to.x_offset - me.x_offset)/stepRemain;
        me.y_offset = me.y_offset + (to.y_offset - me.y_offset)/stepRemain;
        me.z_offset = me.z_offset + (to.z_offset - me.z_offset)/stepRemain;
        me.setView();
    },
};
