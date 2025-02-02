��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2327165688000qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327165686464qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327165685984qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327165683968q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327165682336q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327165687232q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327165682336qX   2327165683968qX   2327165685984qX   2327165686464qX   2327165687232qX   2327165688000qe.(       ~C�>����;9R�Mn���?�ϖ�>�M�T����A?N~�?���F3��yp?�y=6H$?Y|e��?=%p׾�� �ɾ��@8bF?a ?�N=��'=m��@^e�
L�>DO��(�Z?�@�=�UI?]R.�1m���>7*F��^�<��4���	?/�(       '�#>s�˾���>�F��9��>��_<��>��#��>����=���R�:?��?'���׿B��>'�%�t $��A�LL'���?�*?�b����Y��*0�=V�����M�> @�>�'��(v��$7Ⱦn_x>$���ԍ=&�\S�=�'W>ٞ_�@      ���v�Ž_6�qν��챽��^=-�_�6*��
 �=�����8��n�=U2�<,~I� s���ྦ�P�>���= y�<(�%���/�͂V<[:��g+�>[�� �=3t��m�>�������r[�95١�M�����ս��Q?Zy9����7����I4=1[��an��k=��=rC0��7���
��Y=	�>��ҽ�L�K�M��=�Q���x$�܎�[@��g���n�Q>�Q �`~^��鍾||/�!��=�QI>�ڊ�q���}YǾĕ#��`}��O���|=Æ>?0=>hg1�`����R�=j�F��DqJ��,��_ʄ�yN��>����[��>?� U�:2�`> �>��ھ*1>6p��W=>��?����=�����P�H��fu�>)���3��
}k���?�v�:c�?ji��}w��h?d�1����>l���s�Ŀh��=b窿���><6���o<�M�=���6��O��
�ƽC>ن���\�=.-�=����=��ý�X!� ��%�ܽ���=�<Q6 >�o�<"��=/'�=&�!�M: ������$�N�1Z>�l=eͽ��2�.F���<s*��"�������=�7�H���?���w<��7�|����(>Z(?��>*ͽaI??Fp�����o�I�
-���,�δ5�Mˠ��r�>��ӿD!��2.����=�?X?��_�n�����[��A�s.>s�����ļ��T��6?79G�-~ݿ�]?���>�>~0�?�h|�<��>�d > [�:���)�k���=��=[�<��@�Lߟ=3�� A�<2O�6IJ=L��o;��������=#�?��	����w����=n�f��n=�f	��<$���2=!9L��i�b��<���=A�:��ؽ�w�������z�����b��eG$�L���Ψ����t�?`�Ҿ�^¿�|}��Z�>��=ߎC���?J���>	B�>�1��* B�� �>=��Bⴿ6i�;��>�ܰ�/[Y<H=�=��>��>��>A0�>D'�>M��> ����=?��?��>ږ��ҿ�w���=,%+>�q���(�·�r��a.>��,��h= ʼ$3�=å��%�Vu�=�'�>Y�=�k<����n��<9����,��!p��z9�2�˽�l�F>7���"��he=�+��ڑ=�&=��[=�(=�������&��*��<#�=5t%=�湽+����@���s�뭽pؘ<-�0sb��B�T��7	�<!�ٽ��ʾ�/Z��V�|��vp�t۾����'��-T�r��J���T��
Ͻ3�>�2�=̼J��DϾ��>J;����_?��߽jVþ @-��nB�2����Ȯ�����d+?�x?n�Y�vU��x�"A>�����=	�[��MӾ3����q=�o��'I=�	���<>�k��zUн��Ͻ掻�&��Tc���?K�=�	(=�U�3,>�1>��y>2]$�T�˿$�>�vC�2	�>�>�E�@��;�,�>k�H=.��� ?�e�,�=i&��*����(=���=���K�a�����V�<����/�=�`�Δ�=?D��2��=~���)t=�l����p�q��
p��70�6�a��A�=�b���u��ڻ�	��}ٽ�0�?o|=��4=���*;��]UU����<=�9Y��?.>��<ujh=`���	��<'�5��K�맽���=T�)���[�z��.ѽ��0���H��֢������@4�_!�;�|����=Pu[��hB?,���󓊽��2=GJǾ`)u=I*������氾Dڗ������V>(R�ٲ?z��D��CM����;,td�=A���}BX>�Ɗ<ҹ�F��=�`?��ҫn�橎����q<E̾A�y��?N�`�;�#�= �S?����2���2�#�)�M��5��Pa<�=��%���1���=�*?	���"`?���>iv��_�>	N=m�q�r���y�-����>#�u�*�f>�^7�h@��`��=�/*��#�=�|=z��4�_�P����W ��d�=�s^=����?��q�����	���=�X=��p��6(�O��u���6E�=�	�;��������d�=�dŻdy�=���)�w�p����7#��N�[=H%�<����]�!��k=vD��=d��=ZaU���(?&��?��齹3�=ǭ� b}>Xmd����>��<��r�:�#��?騙<L�g? ?�[;W�> $!�1�j?����E=ͣ���n"��Y�>pz������(�>�};���A����o�$h��=�>w�^�2��=\m��1�=�bн������ ���\�����̽.誾�R��������%�����=QfP>�����9��3�6>�����e?�9��Nn2�T��X���>СR��ق>Y���*=��u��_�;x��kk����P=���d��H�J�f?r�/�?}	��&?`��<4q>�u�=�[�=�`���=��ϼP���~�=����FX�R�<W>������L��E*=���XP��%H=tc���|�=@}g���D=���;� �=:A=e��[K =���=��3r=��?���6=ޢa=d�ҽ�����	�D����������c�d�d=Y?]�S�wT�=2T�d��<���;����y[<W�6>���=T>a?�t>�>r�'�i�`�h��֢�y�=?�>1����@>(��>��>���2?LV��=�=�<�=5�+�Ex=>M�?k�W�[�ξz��>�Y �I2��ϓ�������:<���=�ւ<I������(k���(�=���{�����=�ᵽ�տ���ļ���]���[��oí<>	�+I�=	���ȷ= ?C��t`�(Y=or<�>��+4��e<���&?��K=�#㽲�<J��<�hr��)���������DJ��<���>ܲ;?��T=-�|>P,��ڄ<��=D�>t����C�>(G��U�����g>Yg�>ǩ̾��q��'?H�������5�bׂ>+i>�Rr>$�۾K\+?>>�}5?�dF��ˮ>C�>���Hw�[h?*&Y���>���=���=�Gȿ���=�x��xd2=��ýg�����]��+���ڝ�=k ¾�ﱾV9�6��=�G��D��������j�(2���6��6��q1��$�y���=�<O���վ�L�>Am��x�>��!�'1���T?eӾ�w�kA>{g���AR=Ug=?�Ӂ�[r��+���ξ$$,��C�<M|��d�j���~/� �@<�����<���&��[+>�%�>OT��5>��'�D��_R��Ƃ�W�>h>b�3��N-=�$�>?�?}�|?�: >�yU����?���=��ܩz?��O��������L���ݹJ��4�C	�����=�-??Tf�
�����>B &>�� >�A>X�?�r>./�=_�q>�M,?��4��>vr��	�>G�=���>%=kº>1���x>�ϥ>�S�� !�>o�J�y<q>z��=�E�>���>��)���>�@�>&n���0߿8�d>N>|W?mH�<?���B����^�b�9�m�ؽ� >�;=��;�{�����=*�=��R�_>sʋ��7�=@�	=�^���hօ<޳�췭��*ҼQ�Xq�<�V�<-����ǽq���< ֘<�
> 0 <E��� �~:�c��v�N��Z���>��	E>����]y�=��=D���K?�ֈ�=���=�y�=28���,>:=�u=�<���"�[=E|���0y��};=��׼y���r]�=�:��E�]����B�3�~�6��`��F4��`<��̽�=�1��3#=�e�<��=���eA=�M�Z�=4@��ꈾ��辥�#��N?�����6��Q����t�q/ľ`�������ա�7���,�S�¾2W�?8[��fA�Ӯ��+�������=��;�iP>��z�G�>!ѿ��Ͼ�>�r������?Qз>�C�>k�?}�>�-a���4?t�<�'K��H�=�[��̈́��)q	��Gn�z��=>8��#<=W��C�=O�7�����.�a�?=$'������S�=S��=��)= ����2>�๽��S=Az
<H�����=6����<$�����={lV��8���>���9Hٺ���<�='�I�w�!ɖ�P:^���?��S�&�ȹ�`�K餼�M�()/��">�����>�5V��V\?pӻ{��|�ܽ;��=����D���_1���ٽ��1<�	��ೡ�"e��ץ�='`ͽ\6��Kcɽ��y?1��=������>Q5��fʘ����<�/��'?^���0�y<��d��־(֦�����S>2L5�EC���2?�"�ڷ�=[����?iE:�.�V>F¿@�,?#T?W��<�=|��؛�� ˓�wP�>�VI>t�{��H���3?4'Ⱦ!�?
`=T%�=�G�=d,�p�˿�#�����<�56���>r��;C��c+��!~���|���T����=���=c�9��)g=b4�=�0>y�>2(
�	�8�ς��Bn�����I��A��匾Rp�=]6C�rx�>U�$�E��=g,�� J�>�jt=������=j�4�Bv�?��'�Կ�d�������:4>��|�N�= �T;���\L=�j4�����qj��E����;=)�E=M<>�z�&]�[�����,p�=�%�=�s>��X���;K�ܽ��o��J��=�<�FEa�>J�~�<=h��<�Je=iH��E`������
>���=x)��� ���
����Ϟ�U*�Zo�=�ݻ?�r;����H���-T>��+��̻��>U��;�=L���8�?R�����Q�tCP�B��Z�<�b�"���@%�fj�J���0ּ��*��*^=� ���@�N$�??��6>�@V>���>���t���K� g��T?�mo���b�[�#��Q����="*��R=O�uG��#)��.�<�y'>k�����_����=Miڿu�e��5&�Q]?>��)<���>M�<�'�>�l<%�>t"O>��?���eb|���r�CIX>c3��a^�"�����?�M?�9�>�q>lP=��Ӿ��<���>�� ��#��5�n1f�Lw�=R�"=�(���B������L>�u��N�۾E�+>����+�þ�Ӿ���>&�ܽ��>��h�c*����9>�����j>�/>#��Jr2�(|�t�>�V�=��-�5 9�VoZ?�&=3<��A�l>�8~�������<���:�7�����B�;�S����y�E]t;@��<@��R~����޽:Jq=��"��[6��\�O��=�c�)��a�%�Q�&8�=�q�<�
˽�9=��N�n��;��=v�?��%�=�v(����+��dk,=�8��>Ax�*�F�ĨQ� �r��`��H�<Q6�Cȗ=O)�9%8����8!�<�훼�Sj��9d=��<|���s�:�Ƚ+J���%�
�!�JU8������=�띾"W��Qs��+��H�^��Z������B���,��1<b�r�4��5��5Z$=j8>�H������j�f����-����f/�=�j����߷���Q�]��C� ������D�dB�W��c�g;H�M3� �S<|3h���������~I���=v�=�����5=G�l"��肾F��B%���E���K��}Q� ���3=j��;��<n>m��<v���1�潪�2����Kq���G�?��oR����ƽ6-��"}/��pt���=��)>�1���/��A��>�u��g#�DϾ�/�>���=8��=N�=*��9a�bB��o��>�1��L���L�S�迡>����b-2�+"(�FE @}N>騾2 ?eþo�>p���۵���<�}_>��վ���h����牽e�`���$=�,i��D������g�\=�����%=�9��!پEq�gR��O��o��8���(�;(�g=�;:���?2H�= �$�����l���yx�:�I?��?��:#��B��	����k�?�M��o���nX�=��ѻ�����=�읽!��� E�;�X/��p�=� =�ؽ��=��)���#�(�E�!Կ�J�o�#�QS�a�>K�O=� �h1�V�?�yF��D���� N`�Yh&<a�=x/��ww�=�?<��=�f=����ԽU��`�Z=�� =���(       �b?� h�����B��A�"rs�X������ҿ�����p�>p��Qu��@&�G�=P����큾��u�o����@w��ȿ�\=�@vD>��@��r>����~m����=�F��О\�k/�?�i:7>��?��_�|>����x�`RC�       2���(       �h�����>��5?�&���L
�Pb>n��>8��)-?0r���@>
��&?��>�?RA�;#z3�m.�>�t:Ȕ!?�� >�q%���>��1��X?�n�����'Ŧ>�J�O$�>��ܾ�D�>���[��"m��p4��M<��$��˾P#ɽ