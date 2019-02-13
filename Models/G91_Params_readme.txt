The parameter file allows to modify, in a permanent way, some aspects of the aircraft.

Livery:


<PropertyList>
    
    <name type="string" n="0">Liveries</name>
    
    <liveries>
        
        <active>
            <ID>0</ID>
            <setResolution>0</setResolution>
        </active>
        
        <livery n="1">
            <reloads type="float">0.0</reloads>
            <ID type="int">1</ID>
            ....
            
The Liveries tag have an active tag with 2 params:

<ID> and <setResolution> the ID parameter define the Livery number display in the <livery n=i> tag. For example the <ID>1</ID> is the classical PAN livery. The <ID>3</ID> is the military livery.

The <setResolution> param is the resolution:

0 - no livery
1 - 1024 livery
2 - 2048 livery
3 - 4096 livery

You can then select the livery that most interests us and always use that livery and resolution at the start of the program.

Unfortunately, the liveries, once the resolution is defined, can not be resized any more without restarting the aircraft! So if you set non-zero resolution in <active> tag it is impossible to change the resolution from the G91-> Livery!
In the future we hope to solve the problem when those who program the canvas libraries will allow the change of resolution.

For example:

    <liveries>
        
        <active>
            <ID>5</ID>
            <setResolution>3</setResolution>
        </active>
        
        ...
