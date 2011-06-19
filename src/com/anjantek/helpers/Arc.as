package com.anjantek.helpers
{
	public class Arc
	{
		public function Arc()
		{
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private static const EPSILON:Number = 0.00001;  // Roughly 1/1000th of a degree, see below
		
		/**
		 *  Return a array of objects that represent bezier curves which approximate the 
		 *  circular arc centered at the origin, from startAngle to endAngle (radians) with 
		 *  the specified radius.
		 *  
		 *  Each bezier curve is an object with four points, where x1,y1 and 
		 *  x4,y4 are the arc's end points and x2,y2 and x3,y3 are the cubic bezier's 
		 *  control points.
		 */
		public static function createArc(radius:Number, startAngle:Number, endAngle:Number):Array
		{
			// normalize startAngle, endAngle to [-2PI, 2PI]
			
			const twoPI:Number = Math.PI * 2;
			startAngle = startAngle % twoPI
			endAngle = endAngle % twoPI;
			
			// Compute the sequence of arc curves, up to PI/2 at a time.  Total arc angle
			// is less than 2PI.
			
			const curves:Array = [];
			const piOverTwo:Number = Math.PI / 2.0;
			const sgn:Number = (startAngle < endAngle) ? 1 : -1;
			
			var a1:Number = startAngle;
			for (var totalAngle:Number = Math.min(twoPI, Math.abs(endAngle - startAngle)); totalAngle > EPSILON; ) 
			{
				var a2:Number = a1 + sgn * Math.min(totalAngle, piOverTwo);
				curves.push(createSmallArc(radius, a1, a2));
				totalAngle -= Math.abs(a2 - a1);
				a1 = a2;
			}
			
			return curves;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  Cubic bezier approximation of a circular arc centered at the origin, 
		 *  from (radians) a1 to a2, where a2-a1 < pi/2.  The arc's radius is r.
		 * 
		 *  Returns an object with four points, where x1,y1 and x4,y4 are the arc's end points
		 *  and x2,y2 and x3,y3 are the cubic bezier's control points.
		 * 
		 *  This algorithm is based on the approach described in:
		 *  A. Riškus, "Approximation of a Cubic Bezier Curve by Circular Arcs and Vice Versa," 
		 *  Information Technology and Control, 35(4), 2006 pp. 371-378.
		 */
		private static function createSmallArc(r:Number, a1:Number, a2:Number):Object
		{
			// Compute all four points for an arc that subtends the same total angle
			// but is centered on the X-axis
			
			const a:Number = (a2 - a1) / 2.0; // 
			
			const x4:Number = r * Math.cos(a);
			const y4:Number = r * Math.sin(a);
			const x1:Number = x4;
			const y1:Number = -y4
			
			const k:Number = 0.5522847498;
			const f:Number = k * Math.tan(a);
			
			const x2:Number = x1 + f * y4;
			const y2:Number = y1 + f * x4;
			const x3:Number = x2; 
			const y3:Number = -y2;
			
			// Find the arc points actual locations by computing x1,y1 and x4,y4 
			// and rotating the control points by a + a1
			
			const ar:Number = a + a1;
			const cos_ar:Number = Math.cos(ar);
			const sin_ar:Number = Math.sin(ar);
			
			return {
				x1: r * Math.cos(a1), 
					y1: r * Math.sin(a1), 
					x2: x2 * cos_ar - y2 * sin_ar, 
					y2: x2 * sin_ar + y2 * cos_ar, 
					x3: x3 * cos_ar - y3 * sin_ar, 
					y3: x3 * sin_ar + y3 * cos_ar, 
					x4: r * Math.cos(a2), 
					y4: r * Math.sin(a2)};
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}