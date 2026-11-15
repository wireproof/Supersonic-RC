#!/usr/bin/env python3
"""Build an x/z spatial index from the recovered W3D triangles (Y is up)."""
import json, math
from pathlib import Path
root=Path(__file__).resolve().parents[1]
scene=json.loads((root/'research/recovered-3d/world/scene.json').read_text())
meshes={m['id']:m for m in scene['meshes']}
identity=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]
triangles=[]; bins={}; cell=5.0

def multiply(a,b): return [sum(a[k*4+r]*b[c*4+k] for k in range(4)) for c in range(4) for r in range(4)]
def transform(m,v): return [0.01*(sum(m[c*4+r]*v[c] for c in range(3))+m[12+r]) for r in range(3)]
def visit(node,parent):
    matrix=multiply(parent,node.get('transform',identity))
    if node.get('name','').lower() in ('car','arrow'): return
    for mid in node.get('meshIds',[]):
        m=meshes[mid]; p=m['positions']; indices=m['indices']
        vertices=[transform(matrix,p[i:i+3]) for i in range(0,len(p),3)]
        for i in range(0,len(indices)-2,3):
            try: a,b,c=(vertices[indices[i+j]] for j in range(3))
            except (IndexError,TypeError): continue
            det=(b[2]-c[2])*(a[0]-c[0])+(c[0]-b[0])*(a[2]-c[2])
            if abs(det)<1e-7: continue
            idx=len(triangles);triangles.append([round(v,6) for pt in (a,b,c) for v in pt])
            xmin,xmax=math.floor(min(a[0],b[0],c[0])/cell),math.floor(max(a[0],b[0],c[0])/cell)
            zmin,zmax=math.floor(min(a[2],b[2],c[2])/cell),math.floor(max(a[2],b[2],c[2])/cell)
            for x in range(xmin,xmax+1):
                for z in range(zmin,zmax+1): bins.setdefault(f'{x},{z}',[]).append(idx)
    for child in node.get('children',[]): visit(child,matrix)
visit(scene['root'],identity)
out={'cell':cell,'triangles':triangles,'bins':bins}
(root/'App/Resources/ground.json').write_text(json.dumps(out,separators=(',',':')))
print(f'{len(triangles)} ground triangles, {len(bins)} spatial cells')

# Retain near-vertical triangles separately for provisional wall contact.
walls=[]; wall_bins={}
def visit_walls(node,parent):
    matrix=multiply(parent,node.get('transform',identity))
    if node.get('name','').lower() in ('car','arrow'): return
    for mid in node.get('meshIds',[]):
        mesh=meshes[mid]; points=mesh['positions']; indices=mesh['indices']
        vertices=[transform(matrix,points[i:i+3]) for i in range(0,len(points),3)]
        for i in range(0,len(indices)-2,3):
            try:a,b,c=(vertices[indices[i+j]] for j in range(3))
            except (IndexError,TypeError):continue
            ab=[b[j]-a[j] for j in range(3)];ac=[c[j]-a[j] for j in range(3)]
            normal=[ab[1]*ac[2]-ab[2]*ac[1],ab[2]*ac[0]-ab[0]*ac[2],ab[0]*ac[1]-ab[1]*ac[0]]
            length=math.sqrt(sum(v*v for v in normal))
            if length<1e-7 or abs(normal[1])/length>0.65:continue
            idx=len(walls);walls.append([round(v,6) for p in (a,b,c) for v in p])
            for x in range(math.floor(min(a[0],b[0],c[0])/cell),math.floor(max(a[0],b[0],c[0])/cell)+1):
                for z in range(math.floor(min(a[2],b[2],c[2])/cell),math.floor(max(a[2],b[2],c[2])/cell)+1):wall_bins.setdefault(f'{x},{z}',[]).append(idx)
    for child in node.get('children',[]):visit_walls(child,matrix)
visit_walls(scene['root'],identity)
(root/'App/Resources/walls.json').write_text(json.dumps({'cell':cell,'triangles':walls,'bins':wall_bins},separators=(',',':')))
print(f'{len(walls)} wall triangles, {len(wall_bins)} spatial cells')
