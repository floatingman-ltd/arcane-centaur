using System;
using System.Collections.Generic;
using System.Linq;

namespace HelloCs
{
    /// <summary>
    /// Fixture for fold validation. Contains #region blocks (which Roslyn
    /// supplies as LSP fold ranges) alongside ordinary nested constructs, so
    /// both the LSP provider and its treesitter fallback have something to act
    /// on. See openspec TEST_PLAN, change align-treesitter-providers, AT.6.
    /// </summary>
    public class Shapes
    {
        #region Fields

        private readonly List<double> _areas = new();
        private int _count;

        #endregion

        #region Construction

        public Shapes()
        {
            _count = 0;
        }

        public Shapes(IEnumerable<double> seed)
        {
            foreach (var value in seed)
            {
                _areas.Add(value);
                _count++;
            }
        }

        #endregion

        #region Queries

        public double Total()
        {
            var total = 0.0;
            foreach (var area in _areas)
            {
                if (area > 0)
                {
                    total += area;
                }
            }

            return total;
        }

        public string Describe()
        {
            return Total() switch
            {
                > 100 => "large",
                > 10 => "medium",
                _ => "small",
            };
        }

        #endregion
    }
}
