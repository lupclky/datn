import os
import re
import uuid
from xml.dom.minidom import getDOMImplementation

# Configuration
SOURCE_DIR = r"D:\do_an_tot_nghiep\locker_korea\Backend\src\main\java\com\example\Sneakers\models"
OUTPUT_FILE = r"D:\do_an_tot_nghiep\locker_korea\LockerKorea_Analysis.xml"

# Helper to generate unique IDs
def gen_id():
    return "_" + str(uuid.uuid4()).replace("-", "_")

def parse_java_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    class_name_match = re.search(r'public class (\w+)', content)
    if not class_name_match:
        return None
    
    class_name = class_name_match.group(1)
    
    # Remove comments
    content = re.sub(r'//.*', '', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)

    fields = []
    relationships = []

    lines = content.split('\n')
    current_annotations = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        if line.startswith('@'):
            current_annotations.append(line)
            continue
            
        field_match = re.match(r'private\s+([\w<>?,\s]+)\s+(\w+);', line)
        if field_match:
            field_type = field_match.group(1).strip()
            field_name = field_match.group(2).strip()
            
            is_relationship = False
            relation_type = None
            cascade = False
            
            full_annotation_str = " ".join(current_annotations)
            
            if '@OneToMany' in full_annotation_str:
                is_relationship = True
                relation_type = 'OneToMany'
                if 'CascadeType.ALL' in full_annotation_str or 'orphanRemoval = true' in full_annotation_str:
                    cascade = True
                
                generic_match = re.search(r'<(\w+)>', field_type)
                if generic_match:
                    target_class = generic_match.group(1)
                    relationships.append({
                        'type': 'OneToMany',
                        'target': target_class,
                        'cascade': cascade,
                        'field': field_name
                    })

            elif '@ManyToOne' in full_annotation_str:
                is_relationship = True
                relationships.append({
                    'type': 'ManyToOne',
                    'target': field_type,
                    'field': field_name
                })

            elif '@OneToOne' in full_annotation_str:
                is_relationship = True
                relationships.append({
                    'type': 'OneToOne',
                    'target': field_type,
                    'field': field_name
                })
            
            elif '@ManyToMany' in full_annotation_str:
                is_relationship = True
                generic_match = re.search(r'<(\w+)>', field_type)
                if generic_match:
                    target_class = generic_match.group(1)
                    relationships.append({
                        'type': 'ManyToMany',
                        'target': target_class,
                        'field': field_name
                    })

            if not is_relationship:
                simple_type = field_type.split('.')[-1]
                fields.append({'name': field_name, 'type': simple_type})
            
            current_annotations = []
        
        elif 'class ' in line:
            current_annotations = []

    return {
        'name': class_name,
        'fields': fields,
        'relationships': relationships,
        'id': gen_id()
    }

def create_xmi(classes):
    impl = getDOMImplementation()
    # Use the XMI namespace URI
    doc = impl.createDocument("http://schema.omg.org/spec/XMI/2.1", "xmi:XMI", None)
    root = doc.documentElement
    # root.setAttribute("xmi:version", "2.1") # Already implied by namespace in some parsers, but let's keep attributes
    # We need to add the xmlns attributes manually if minidom doesn't do it automatically for the root
    # But createDocument with namespace might handle the prefix.
    
    # Let's try a simpler approach: Create generic XML and set attributes manually to avoid namespace strictness issues in simple scripts
    # But minidom createDocument is strict.
    # Let's use a hack: createDocument(None, "XMI", None) and then set tagName to xmi:XMI? No.
    
    # Correct way with minidom and namespaces is verbose.
    # Let's switch to string formatting for the root to avoid this headache, 
    # or just use ElementTree which is standard in Python.
    
    import xml.etree.ElementTree as ET
    
    # Define namespaces
    XMI_NS = "http://schema.omg.org/spec/XMI/2.1"
    UML_NS = "http://www.eclipse.org/uml2/3.0.0/UML"
    
    ET.register_namespace('xmi', XMI_NS)
    ET.register_namespace('uml', UML_NS)
    
    # Create root with QName
    root = ET.Element(f"{{{XMI_NS}}}XMI")
    root.set(f"{{{XMI_NS}}}version", "2.1")
    
    model = ET.SubElement(root, f"{{{UML_NS}}}Model")
    model.set(f"{{{XMI_NS}}}id", gen_id())
    model.set("name", "LockerKorea_Backend")

    # Define Primitive Types
    primitive_types = ["String", "Long", "Integer", "Boolean", "Date", "LocalDateTime", "LocalDate", "Double", "int", "boolean"]
    type_ids = {}
    for pt in primitive_types:
        el = ET.SubElement(model, "packagedElement")
        el.set(f"{{{XMI_NS}}}type", "uml:PrimitiveType")
        tid = gen_id()
        el.set(f"{{{XMI_NS}}}id", tid)
        el.set("name", pt)
        type_ids[pt] = tid

    # Create Package
    pkg = ET.SubElement(model, "packagedElement")
    pkg.set(f"{{{XMI_NS}}}type", "uml:Package")
    pkg.set(f"{{{XMI_NS}}}id", gen_id())
    pkg.set("name", "com.example.Sneakers.models")

    # First pass: Create Classes
    class_map = {}
    for cls in classes:
        class_el = ET.SubElement(pkg, "packagedElement")
        class_el.set(f"{{{XMI_NS}}}type", "uml:Class")
        class_el.set(f"{{{XMI_NS}}}id", cls['id'])
        class_el.set("name", cls['name'])
        class_map[cls['name']] = cls
        cls['element'] = class_el

    # Second pass: Add Attributes and Relationships
    for cls in classes:
        class_el = cls['element']
        
        # Attributes
        for field in cls['fields']:
            attr = ET.SubElement(class_el, "ownedAttribute")
            attr.set(f"{{{XMI_NS}}}type", "uml:Property")
            attr.set(f"{{{XMI_NS}}}id", gen_id())
            attr.set("name", field['name'])
            attr.set("visibility", "private")
            
            ftype = field['type']
            if ftype in type_ids:
                attr.set("type", type_ids[ftype])
            else:
                if ftype in class_map:
                    attr.set("type", class_map[ftype]['id'])
                else:
                    attr.set("type", type_ids.get("String")) 
            

        # Relationships
        for rel in cls['relationships']:
            target_name = rel['target']
            if target_name not in class_map:
                continue
            
            target_cls = class_map[target_name]
            
            if rel['type'] == 'OneToMany':
                assoc = ET.SubElement(pkg, "packagedElement")
                assoc.set(f"{{{XMI_NS}}}type", "uml:Association")
                assoc_id = gen_id()
                assoc.set(f"{{{XMI_NS}}}id", assoc_id)
                
                # End 1: The container (Source)
                end1 = ET.SubElement(assoc, "ownedEnd")
                end1.set(f"{{{XMI_NS}}}type", "uml:Property")
                end1.set(f"{{{XMI_NS}}}id", gen_id())
                end1.set("name", cls['name'].lower())
                end1.set("type", cls['id'])
                end1.set("association", assoc_id)
                
                lower1 = ET.SubElement(end1, "lowerValue")
                lower1.set(f"{{{XMI_NS}}}type", "uml:LiteralInteger")
                lower1.set(f"{{{XMI_NS}}}id", gen_id())
                lower1.set("value", "1")
                
                upper1 = ET.SubElement(end1, "upperValue")
                upper1.set(f"{{{XMI_NS}}}type", "uml:LiteralUnlimitedNatural")
                upper1.set(f"{{{XMI_NS}}}id", gen_id())
                upper1.set("value", "1")
                
                # End 2: The part (Target)
                end2 = ET.SubElement(assoc, "ownedEnd")
                end2.set(f"{{{XMI_NS}}}type", "uml:Property")
                end2.set(f"{{{XMI_NS}}}id", gen_id())
                end2.set("name", rel['field'])
                end2.set("type", target_cls['id'])
                end2.set("association", assoc_id)
                
                if rel['cascade']:
                    end1.set("aggregation", "composite")
                else:
                    end1.set("aggregation", "shared")

                lower2 = ET.SubElement(end2, "lowerValue")
                lower2.set(f"{{{XMI_NS}}}type", "uml:LiteralInteger")
                lower2.set(f"{{{XMI_NS}}}id", gen_id())
                lower2.set("value", "0")
                
                upper2 = ET.SubElement(end2, "upperValue")
                upper2.set(f"{{{XMI_NS}}}type", "uml:LiteralUnlimitedNatural")
                upper2.set(f"{{{XMI_NS}}}id", gen_id())
                upper2.set("value", "*")

    # Convert to string and pretty print
    xml_str = ET.tostring(root, encoding='utf-8')
    
    # Use minidom for pretty printing
    from xml.dom import minidom
    reparsed = minidom.parseString(xml_str)
    return reparsed.toprettyxml(indent="  ")

def main():
    classes = []
    if not os.path.exists(SOURCE_DIR):
        print(f"Directory not found: {SOURCE_DIR}")
        return

    for filename in os.listdir(SOURCE_DIR):
        if filename.endswith(".java"):
            file_path = os.path.join(SOURCE_DIR, filename)
            class_data = parse_java_file(file_path)
            if class_data:
                classes.append(class_data)
    
    xmi_content = create_xmi(classes)
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(xmi_content)
    
    print(f"Generated XMI file at: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
